/*
 * generated by Xtext 2.17.0
 */
package app.hypermedia.testing.dsl.generator

import app.hypermedia.testing.dsl.core.*
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import org.apache.commons.lang3.NotImplementedException
import org.eclipse.emf.ecore.EObject
import app.hypermedia.testing.dsl.Modifier
import org.json.JSONObject
import org.json.JSONArray
import java.util.Map
import java.util.HashMap
import org.eclipse.emf.common.util.EList
import java.math.BigDecimal

/**
 * Generates code from your model files on save.
 *
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class CoreGenerator extends AbstractGenerator {
    final static int INDENTATION = 2

    override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
        val scenario = new JSONObject()

        val entrypoint = getEntrypoint(resource.contents)
        if (entrypoint !== null) {
            scenario.put('entrypoint', entrypoint)
        }

        val defaultHeaders = getDefaultHeaders(resource.contents)
        if (defaultHeaders !== null) {
            scenario.put('defaultHeaders', defaultHeaders)
        }

        val Iterable<TopLevelStep> blocks = getScenarioSteps(resource.contents).toList
        if ( ! blocks.empty) {
            scenario.put('steps', generateSteps(blocks))
        }

        val String dslFileName = resource.getURI().lastSegment.toString();

        fsa.generateFile(dslFileName + '.hypertest.json', scenario.toString(INDENTATION));
    }

    def generateSteps(Iterable<TopLevelStep> blocks) {
        val steps = new JSONArray()

        for (block : blocks) {
            val stepJson = block.step
            steps.put(new JSONObject(stepJson.toString()))
        }

        return steps
    }

    def buildBlock(
        String type,
        Iterable<? extends EObject> children,
        Iterable<? extends EObject> constraints,
        Map<String, Object> map
    ) {
        map.put('children', children.map([c | c.step]).toList())

        if (constraints.size > 0) {
            map.put('constraints', constraints.map([c | c.constraint ]).toList())
        }

        return buildStatement(type, map)
    }

    def buildStatement(String type, Map<String, Object> map) {
        val step = new JSONObject(map)
        step.put('type', type)

        return step
    }

    def dispatch step(ClassBlock cb)  {
        val map = new HashMap<String, Object>
        map.put('classId', cb.name.identifier)

        return buildBlock('Class', cb.children, cb.constraints, map)
    }

    def dispatch step(PropertyBlock it) {
        val map = new HashMap<String, Object>
        map.put('propertyId', name.identifier)
        map.put('strict', modifier != Modifier.WITH)

        return buildBlock('Property', children, constraints, map)
    }

    def dispatch step(PropertyStatement it) {
        val map = new HashMap<String, Object>
        map.put('propertyId', name.identifier)
        map.put('strict', true)

        if(expectation !== null) {
            map.put('value', expectation.propertyValue)
        }

        return buildStatement('Property', map)
    }

    def dispatch step(StatusStatement it) {
        val map = new HashMap<String, Object>
        map.put('code', status)

        return buildStatement('ResponseStatus', map)
    }

    def dispatch step(RelaxedLinkBlock it) {
        val map = new HashMap<String, Object>
        map.put('rel', relation.identifier)
        map.put('strict', false)

        return buildBlock('Link', children, constraints, map)
    }

    def dispatch step(StrictLinkBlock it) {
        val map = new HashMap<String, Object>
        map.put('rel', relation.identifier)
        map.put('strict', true)

        return buildBlock('Link', children, constraints, map)
    }

    def dispatch step(LinkStatement it) {
        val map = new HashMap<String, Object>
        map.put('rel', relation.identifier)
        map.put('strict', true)

        return buildStatement('Link', map)
    }

    def dispatch step(HeaderStatement it) {
        val map = new HashMap<String, Object>
        map.put('header', fieldName)

        if (regex !== null) {
            map.put('pattern', regex.pattern)
        }

        if (exactValue !== null) {
            map.put('value', exactValue)
        }

        if (variable !== null) {
             map.put('captureAs', variable)
        }

        return buildStatement('ResponseHeader', map)
    }

    def dispatch step(FollowStatement it) {
        val map = new HashMap<String, Object>
        map.put('variable', variable)

        return buildStatement('Follow', map)
    }

    def dispatch step(EObject step) {
        throw new NotImplementedException(String.format("Unrecognized step %s", step.class))
    }

    def dispatch constraint(PropertyConstraint it) {
         val negatedCondition = negation !== null

        val map = new HashMap<String, Object>
        map.put('constrain', 'Property')
        map.put('left', name.identifier)
        map.put('operator', condition.operator)
        map.put('right', condition.operand)
        map.put('negated', negatedCondition)

        return new JSONObject(map)
    }

    def dispatch constraint(StatusConstraint it) {
         val negatedCondition = negation !== null

        val map = new HashMap<String, Object>
        map.put('constrain', 'Status')
        map.put('operator', condition.operator)
        map.put('right', condition.operand)
        map.put('negated', negatedCondition)

        return new JSONObject(map)
    }

    def dispatch constraint(EObject condition) {
        throw new NotImplementedException(String.format("Unrecognized constraint %s", condition.class))
    }

    def dispatch operand(StringCondition it) {
        return value
    }

    def dispatch operand(RegexCondition it) {
        return value
    }

    def dispatch operand(BooleanCondition it) {
        return value == 'true' ? true : false
    }

    def dispatch operand(IntCondition it) {
        return value
    }

    def dispatch operand(DecimalCondition it) {
        return value
    }

    def dispatch operand(CustomCondition it) {
        return value
    }

    def dispatch operand(EObject it) {
        throw new NotImplementedException(String.format("Unrecognized condition %s", class))
    }


    def mapArithmeticOperator(String relation) {
        if (relation.startsWith('Equal')) {
            return 'eq'
        }

        switch (relation) {
            case 'Less Than': {
                return 'lt'
            }
            case 'Greater Than': {
                return 'gt'
            }
            case 'Less Than Or Equal': {
                return 'le'
            }
            case 'Greater Than Or Equal': {
                return 'ge'
            }
            default: {
                throw new NotImplementedException(String.format("Unrecognized operator %s", relation))
            }
        }
    }

    def dispatch String operator(IntCondition it) {
        return operator.mapArithmeticOperator
    }

    def dispatch String operator(DecimalCondition it) {
        return operator.mapArithmeticOperator
    }

    def dispatch String operator(RegexCondition it) {
        return 'regex'
    }

    def dispatch String operator(BooleanCondition it) {
        return operator.mapArithmeticOperator
    }

    def dispatch String operator(StringCondition it) {
        return operator.mapArithmeticOperator
    }

    def dispatch String operator(CustomCondition it) {
        return 'function'
    }

    def dispatch operator(EObject it) {
        throw new NotImplementedException(String.format("Unrecognized operator %s", class))
    }

    def dispatch identifier(Identifier it) {
        return value
    }

    def dispatch Object propertyValue(StringValue it) {
        return value
    }

    def dispatch Object propertyValue(BooleanValue it) {
        return value == 'true' ? true : false
    }

    def dispatch Object propertyValue(IntValue it) {
        return value
    }

    def dispatch Object propertyValue(DecimalValue it) {
        return new BigDecimal(value)
    }

    protected def getScenarioSteps(EList<EObject> s) {
        return s.filter(CoreScenario).flatMap[cs |cs.steps]
    }

    protected def getEntrypointStep(EList<EObject> contents) {
        return contents
           .filter(CoreScenario)
           .map[s | s.entrypoint]
           .head
    }

    protected def getDefaultHeadersBlock(EList<EObject> contents) {
        return contents
           .filter(CoreScenario)
           .map[s | s.defaultHeaders]
           .head
    }

    private def getEntrypoint(EList<EObject> contents) {
    	val entrypointStatement = getEntrypointStep(contents)

    	if (entrypointStatement !== null) {
    	    return entrypointStatement.path
    	}

    	return null
    }
    
    private def getDefaultHeaders(EList<EObject> contents) {
        val headersBlock = getDefaultHeadersBlock(contents)
        
        if (headersBlock !== null) {
            val map = new HashMap<String, JSONArray>
            headersBlock.headers
                .groupBy[header | header.fieldName ]
                .forEach[fieldName, values | {
                    map.put(fieldName, new JSONArray(values.map[header | header.value]))
                }]
        
            return new JSONObject(map)
        }

        return null
    }
}
