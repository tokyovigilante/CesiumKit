//
//  ShaderSource.swift
//  CesiumKit
//
//  Created by Ryan Walklin on 7/03/15.
//  Copyright (c) 2015 Test Toast. All rights reserved.
//

import Foundation

private class DependencyNode: Equatable {
    
    var name: String
    
    var glslSource: String
    
    var dependsOn = [DependencyNode]()
    
    var requiredBy = [DependencyNode]()
    
    var evaluated: Bool = false
    
    init (
        name: String,
        glslSource: String,
        dependsOn: [DependencyNode] = [DependencyNode](),
        requiredBy: [DependencyNode] = [DependencyNode](),
        evaluated: Bool = false)
    {
        self.name = name
        self.glslSource = glslSource
        self.dependsOn = dependsOn
        self.requiredBy = requiredBy
        self.evaluated = evaluated
    }
}

private func == (left: DependencyNode, right: DependencyNode) -> Bool {
    return left.name == right.name &&
        left.glslSource == right.glslSource
}

/**
* An object containing various inputs that will be combined to form a final GLSL shader string.
*
* @param {Object} [options] Object with the following properties:
* @param {String[]} [options.sources] An array of strings to combine containing GLSL code for the shader.
* @param {String[]} [options.defines] An array of strings containing GLSL identifiers to <code>#define</code>.
* @param {String} [options.pickColorQualifier] The GLSL qualifier, <code>uniform</code> or <code>varying</code>, for the input <code>czm_pickColor</code>.  When defined, a pick fragment shader is generated.
* @param {Boolean} [options.includeBuiltIns=true] If true, referenced built-in functions will be included with the combined shader.  Set to false if this shader will become a source in another shader, to avoid duplicating functions.
*
* @exception {DeveloperError} options.pickColorQualifier must be 'uniform' or 'varying'.
*
* @example
* // 1. Prepend #defines to a shader
* var source = new Cesium.ShaderSource({
*   defines : ['WHITE'],
*   sources : ['void main() { \n#ifdef WHITE\n gl_FragColor = vec4(1.0); \n#else\n gl_FragColor = vec4(0.0); \n#endif\n }']
* });
*
* // 2. Modify a fragment shader for picking
* var source = new Cesium.ShaderSource({
*   sources : ['void main() { gl_FragColor = vec4(1.0); }'],
*   pickColorQualifier : 'uniform'
* });
*
* @private
*/
struct ShaderSource {
    
    var sources: [String]
    
    var defines: [String]

    var pickColorQualifier: String?
    
    let includeBuiltIns: Bool
    fileprivate let _commentRegex = "/\\*\\*[\\s\\S]*?\\*/"
    fileprivate let _versionRegex = "/#version\\s+(.*?)\n"
    fileprivate let _lineRegex = "\\n"
    fileprivate let _czmRegex = "\\bczm_[a-zA-Z0-9_]*"

    init (sources: [String] = [String](), defines: [String] = [String](), pickColorQualifier: String? = nil, includeBuiltIns: Bool = true) {
        
        assert(pickColorQualifier == nil || pickColorQualifier == "uniform" || pickColorQualifier == "varying", "options.pickColorQualifier must be 'uniform' or 'varying'.")
    
        self.defines = defines
        self.sources = sources
        self.pickColorQualifier = pickColorQualifier
        self.includeBuiltIns = includeBuiltIns
    }

    /**
    * Create a single string containing the full, combined vertex shader with all dependencies and defines.
    *
    * @returns {String} The combined shader string.
    */
    func createCombinedVertexShader () -> String {
        return combineShader(false)
    }
    
    /**
    * Create a single string containing the full, combined fragment shader with all dependencies and defines.
    *
    * @returns {String} The combined shader string.
    */
    func createCombinedFragmentShader () -> String {
        return combineShader(true)
    }

    func combineShader(_ isFragmentShader: Bool) -> String {
        
        // Combine shader sources, generally for pseudo-polymorphism, e.g., czm_getMaterial.
        var combinedSources = ""
        
        for (i, source) in sources.enumerated() {
                // #line needs to be on its own line.
                combinedSources += "\n#line 0\n" + sources[i];
        }
        
        combinedSources = removeComments(combinedSources)
        
        var version: String? = nil
        
        // Extract existing shader version from sources
        let versionRange = combinedSources[_versionRegex].range()
        if versionRange.location != NSNotFound {
            version = (combinedSources as NSString).substring(with: versionRange)
            combinedSources.replace(version!, "\n")
        }
        
        // Replace main() for picked if desired.
        if pickColorQualifier != nil {
            // FIXME: pickColorQualifier
            /*combinedSources = combinedSources.replace(/void\s+main\s*\(\s*(?:void)?\s*\)/g, 'void czm_old_main()');
            combinedSources += '\
            \n' + pickColorQualifier + ' vec4 czm_pickColor;\n\
            void main()\n\
            {\n\
                czm_old_main();\n\
                if (gl_FragColor.a == 0.0) {\n\
                    discard;\n\
                }\n\
                gl_FragColor = czm_pickColor;\n\
            }';*/
        }
        
        // combine into single string
        var result = ""
        
        // #version must be first
        // defaults to #version 100 if not specified
        if version != nil {
            result = "#version " + version!
        }
        
        // Prepend #defines for uber-shaders
        for define in defines {
            if define.characters.count != 0 {
                result += "#define " + define + "\n"
            }
        }
        
        // append built-ins
        if includeBuiltIns {
            result += getBuiltinsAndAutomaticUniforms(combinedSources)
        }
        
        // reset line number
        result += "\n#line 0\n"
        
        // append actual source
        result += combinedSources
        
        return result
    }

    fileprivate func removeComments (_ source: String) -> String {
        // strip doc comments so we don't accidentally try to determine a dependency for something found
        // in a comment
        var newSource = source
        let commentBlocks = newSource[_commentRegex].matches()
        
        if commentBlocks.count > 0 {
            for comment in commentBlocks {
                let numberOfLines = comment[_lineRegex].matches().count
                
                // preserve the number of lines in the comment block so the line numbers will be correct when debugging shaders
                var modifiedComment = ""
                for lineNumber in 0..<numberOfLines {
                    modifiedComment += "//\n"
                }
                newSource = newSource.replace(comment, modifiedComment)
            }
        }
        return newSource
    }

    fileprivate func getBuiltinsAndAutomaticUniforms(_ shaderSource: String) -> String {
        // generate a dependency graph for builtin functions
        
        var dependencyNodes = [DependencyNode]()
        let root = getDependencyNode("main", glslSource: shaderSource, nodes: &dependencyNodes)
        generateDependencies(root, dependencyNodes: &dependencyNodes)
        sortDependencies(&dependencyNodes)
        
        // Concatenate the source code for the function dependencies.
        // Iterate in reverse so that dependent items are declared before they are used.
        return Array(dependencyNodes.reversed())
            .reduce("", { $0 + $1.glslSource + "\n" })
            .replace(root.glslSource, "")
    }
    
    fileprivate func getDependencyNode(_ name: String, glslSource: String, nodes: inout [DependencyNode]) -> DependencyNode {
        
        var dependencyNode: DependencyNode?
        
        // check if already loaded
        for node in nodes {
            if node.name == name {
                dependencyNode = node
            }
        }
        
        if dependencyNode == nil {
            // strip doc comments so we don't accidentally try to determine a dependency for something found
            // in a comment
            let newGLSLSource = removeComments(glslSource)
            
            // create new node
            dependencyNode = DependencyNode(name: name, glslSource: newGLSLSource)
            nodes.append(dependencyNode!)
        }
        return dependencyNode!
    }
    
    fileprivate func generateDependencies(_ currentNode: DependencyNode, dependencyNodes: inout [DependencyNode]) {
        
        if currentNode.evaluated {
            return
        }
        currentNode.evaluated = true
        
        // identify all dependencies that are referenced from this glsl source code
        let czmMatches = deleteDuplicates(currentNode.glslSource[_czmRegex].matches())
        for match in czmMatches {
            if (match != currentNode.name) {
                var elementSource: String? = nil
                if let builtin = Builtins[match] {
                    elementSource = builtin
                } else if let uniform = AutomaticUniforms[match] {
                    elementSource = uniform.declaration(match)
                } else {
                    logPrint(.warning, "uniform \(match) not found")
                }
                if elementSource != nil {
                    let referencedNode = getDependencyNode(match, glslSource: elementSource!, nodes: &dependencyNodes)
                    currentNode.dependsOn.append(referencedNode)
                    referencedNode.requiredBy.append(currentNode)
                    
                    // recursive call to find any dependencies of the new node
                    generateDependencies(referencedNode, dependencyNodes: &dependencyNodes)
                }
                
            }
        }
    }
    
    fileprivate func sortDependencies(_ dependencyNodes: inout [DependencyNode]) {
        
        var nodesWithoutIncomingEdges = [DependencyNode]()
        var allNodes = [DependencyNode]()
        
        while (dependencyNodes.count > 0) {
            let node = dependencyNodes.removeLast()
            allNodes.append(node)
            
            if node.requiredBy.count == 0 {
                nodesWithoutIncomingEdges.append(node)
            }
        }
        
        while nodesWithoutIncomingEdges.count > 0 {
            let currentNode = nodesWithoutIncomingEdges.remove(at: 0)
            
            dependencyNodes.append(currentNode)
            for i in 0..<currentNode.dependsOn.count {
                // remove the edge from the graph
                let referencedNode = currentNode.dependsOn[i]
                let index = referencedNode.requiredBy.index(of: currentNode)
                if (index != nil) {
                    referencedNode.requiredBy.remove(at: index!)
                }
                
                // if referenced node has no more incoming edges, add to list
                if referencedNode.requiredBy.count == 0 {
                    nodesWithoutIncomingEdges.append(referencedNode)
                }
            }
        }
        
        // if there are any nodes left with incoming edges, then there was a circular dependency somewhere in the graph
        var badNodes = [DependencyNode]()
        for node in allNodes {
            if node.requiredBy.count != 0 {
                badNodes.append(node)
            }
        }
        if badNodes.count != 0 {
            var message = "A circular dependency was found in the following built-in functions/structs/constants: \n"
            for node in badNodes {
                message += node.name + "\n"
            }
            assertionFailure(message)
        }
    }


}
