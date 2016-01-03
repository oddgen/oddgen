package trivadis.oddgen.sqldev.tests

import org.junit.Assert
import org.junit.Test
import trivadis.oddgen.sqldev.model.PreferenceModel

class PreferenceModelTest {
	@Test
	def void testDefaultOfIsDiscoverPlsqlGenerators() {
		val PreferenceModel model = PreferenceModel.getInstance(null)
		Assert.assertTrue(model.isDiscoverPlsqlGenerators)
	}
}
