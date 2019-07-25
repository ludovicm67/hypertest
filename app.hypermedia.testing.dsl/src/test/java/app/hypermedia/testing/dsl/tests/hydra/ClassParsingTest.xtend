/*
 * generated by Xtext 2.18.0
 */
package app.hypermedia.testing.dsl.tests.hydra

import app.hypermedia.testing.dsl.core.CorePackage
import app.hypermedia.testing.dsl.hydra.HydraScenario
import app.hypermedia.testing.dsl.tests.HydraInjectorProvider
import com.google.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.testing.util.ParseHelper
import org.eclipse.xtext.testing.validation.ValidationTestHelper
import org.junit.jupiter.api.^extension.ExtendWith
import org.junit.jupiter.params.ParameterizedTest
import org.junit.jupiter.params.provider.MethodSource
import org.junit.jupiter.api.Test
import static org.assertj.core.api.Assertions.*
import app.hypermedia.testing.dsl.tests.TestHelpers
import app.hypermedia.testing.dsl.core.ClassBlock

@ExtendWith(InjectionExtension)
@InjectWith(HydraInjectorProvider)
class ClassParsingTest {
    @Inject extension ParseHelper<HydraScenario>
    @Inject extension ValidationTestHelper

    @ParameterizedTest
    @MethodSource("app.hypermedia.testing.dsl.tests.hydra.TestCases#invalidUris")
    def void classWithInvalidUri_failsValidation(String id) {
        // when
        val result = '''
            With Class <«id»> { }
        '''.parse

        // then
        result.assertError(
            CorePackage.Literals.CLASS_BLOCK,
            null,
            "Value is not a valid URI"
        )
    }

    @ParameterizedTest
    @MethodSource("app.hypermedia.testing.dsl.tests.hydra.TestCases#validUris")
    def void classWithValidUri_passesValidation(String id) {
        // when
        val result = '''
            With Class <«id»> { }
        '''.parse

        // then
        result.assertNoIssues()
    }

    @Test
    def void prefixedName_termCanContainNonLetterCharacters() {
        // when
        val result = '''
            PREFIX ex: <http://example.com/>
            
            With Class ex:123/foo%20bar {
                
            }
        '''.parse

        // then
        TestHelpers.assertModelParsedSuccessfully(result)

        val classBlock = result.steps.get(0) as ClassBlock
        assertThat(classBlock.name.value).isEqualTo('ex:123/foo%20bar')
    }
}
