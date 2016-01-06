package org.oddgen.sqldev.tests

import com.jcabi.log.Logger
import org.junit.Assert
import org.junit.Test
import org.oddgen.sqldev.model.PreferenceModel

class PreferenceModelTest {
	@Test
	def void testDefaultOfIsDiscoverPlsqlGenerators() {
		val PreferenceModel model = PreferenceModel.getInstance(null)
		Logger.info(this, "model: " + model)
		Assert.assertTrue(model.isDiscoverPlsqlGenerators)
	}
}
