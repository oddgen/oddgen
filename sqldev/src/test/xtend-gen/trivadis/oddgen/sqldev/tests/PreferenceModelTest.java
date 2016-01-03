package trivadis.oddgen.sqldev.tests;

import org.junit.Assert;
import org.junit.Test;
import trivadis.oddgen.sqldev.model.PreferenceModel;

@SuppressWarnings("all")
public class PreferenceModelTest {
  @Test
  public void testDefaultOfIsDiscoverPlsqlGenerators() {
    final PreferenceModel model = PreferenceModel.getInstance(null);
    boolean _isDiscoverPlsqlGenerators = model.isDiscoverPlsqlGenerators();
    Assert.assertTrue(_isDiscoverPlsqlGenerators);
  }
}
