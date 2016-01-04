package trivadis.oddgen.sqldev.tests;

import com.jcabi.log.Logger;
import org.junit.Assert;
import org.junit.Test;
import trivadis.oddgen.sqldev.model.PreferenceModel;

@SuppressWarnings("all")
public class PreferenceModelTest {
  @Test
  public void testDefaultOfIsDiscoverPlsqlGenerators() {
    final PreferenceModel model = PreferenceModel.getInstance(null);
    Logger.info(this, ("model: " + model));
    boolean _isDiscoverPlsqlGenerators = model.isDiscoverPlsqlGenerators();
    Assert.assertTrue(_isDiscoverPlsqlGenerators);
  }
}
