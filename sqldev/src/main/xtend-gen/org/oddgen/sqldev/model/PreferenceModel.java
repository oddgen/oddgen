/**
 * Copyright 2015 Philipp Salvisberg <philipp.salvisberg@trivadis.com>
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *     http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.oddgen.sqldev.model;

import com.jcabi.aspects.Loggable;
import oracle.javatools.data.HashStructure;
import oracle.javatools.data.HashStructureAdapter;
import oracle.javatools.data.PropertyStorage;
import org.oddgen.sqldev.LoggableConstants;

@Loggable(value = LoggableConstants.DEBUG, prepend = true)
@SuppressWarnings("all")
public class PreferenceModel extends HashStructureAdapter {
  private final static String DATA_KEY = "oddgen";
  
  private PreferenceModel(final HashStructure hash) {
    super(hash);
  }
  
  public static PreferenceModel getInstance(final PropertyStorage prefs) {
    HashStructure _findOrCreate = HashStructureAdapter.findOrCreate(prefs, PreferenceModel.DATA_KEY);
    return new PreferenceModel(_findOrCreate);
  }
  
  /**
   * enabled/disable automatic discovery of PL/SQL Generations when opening an oddgen node
   */
  private final static String KEY_DISCOVER_PLSQL_GENERATORS = "discoverPlsqlGenerators";
  
  public boolean isDiscoverPlsqlGenerators() {
    HashStructure _hashStructure = this.getHashStructure();
    return _hashStructure.getBoolean(PreferenceModel.KEY_DISCOVER_PLSQL_GENERATORS, true);
  }
  
  public void setDiscoverPlsqlGenerators(final boolean discoverPlsqlGenerators) {
    HashStructure _hashStructure = this.getHashStructure();
    _hashStructure.putBoolean(PreferenceModel.KEY_DISCOVER_PLSQL_GENERATORS, discoverPlsqlGenerators);
  }
}
