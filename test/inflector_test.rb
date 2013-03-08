require 'abstract_unit'
require 'motion_support/inflector/inflections'
require 'motion_support/inflector/transliterate'
require 'motion_support/inflector/methods'

require 'motion_support/inflections'
require 'motion_support/core_ext/string/inflections'

require 'inflector_test_cases'
require 'constantize_test_cases'

class InflectorTest < Test::Unit::TestCase
  include InflectorTestCases
  include ConstantizeTestCases

  def test_pluralize_plurals
    assert_equal "plurals", MotionSupport::Inflector.pluralize("plurals")
    assert_equal "Plurals", MotionSupport::Inflector.pluralize("Plurals")
  end

  def test_pluralize_empty_string
    assert_equal "", MotionSupport::Inflector.pluralize("")
  end

  MotionSupport::Inflector.inflections.uncountable.each do |word|
    define_method "test_uncountability_of_#{word}" do
      assert_equal word, MotionSupport::Inflector.singularize(word)
      assert_equal word, MotionSupport::Inflector.pluralize(word)
      assert_equal MotionSupport::Inflector.pluralize(word), MotionSupport::Inflector.singularize(word)
    end
  end

  def test_uncountable_word_is_not_greedy
    uncountable_word = "ors"
    countable_word = "sponsor"

    cached_uncountables = MotionSupport::Inflector.inflections.uncountables

    MotionSupport::Inflector.inflections.uncountable << uncountable_word

    assert_equal uncountable_word, MotionSupport::Inflector.singularize(uncountable_word)
    assert_equal uncountable_word, MotionSupport::Inflector.pluralize(uncountable_word)
    assert_equal MotionSupport::Inflector.pluralize(uncountable_word), MotionSupport::Inflector.singularize(uncountable_word)

    assert_equal "sponsor", MotionSupport::Inflector.singularize(countable_word)
    assert_equal "sponsors", MotionSupport::Inflector.pluralize(countable_word)
    assert_equal "sponsor", MotionSupport::Inflector.singularize(MotionSupport::Inflector.pluralize(countable_word))

  ensure
    MotionSupport::Inflector.inflections.instance_variable_set :@uncountables, cached_uncountables
  end

  SingularToPlural.each do |singular, plural|
    define_method "test_pluralize_singular_#{singular}" do
      assert_equal(plural, MotionSupport::Inflector.pluralize(singular))
      assert_equal(plural.capitalize, MotionSupport::Inflector.pluralize(singular.capitalize))
    end
  end

  SingularToPlural.each do |singular, plural|
    define_method "test_singularize_plural_#{plural}" do
      assert_equal(singular, MotionSupport::Inflector.singularize(plural))
      assert_equal(singular.capitalize, MotionSupport::Inflector.singularize(plural.capitalize))
    end
  end

  SingularToPlural.each do |singular, plural|
    define_method "test_pluralize_plural_#{plural}" do
      assert_equal(plural, MotionSupport::Inflector.pluralize(plural))
      assert_equal(plural.capitalize, MotionSupport::Inflector.pluralize(plural.capitalize))
    end
  end

  def test_overwrite_previous_inflectors
    assert_equal("series", MotionSupport::Inflector.singularize("series"))
    MotionSupport::Inflector.inflections.singular "series", "serie"
    assert_equal("serie", MotionSupport::Inflector.singularize("series"))
    MotionSupport::Inflector.inflections.uncountable "series" # Return to normal
  end

  MixtureToTitleCase.each do |before, titleized|
    define_method "test_titleize_#{before}" do
      assert_equal(titleized, MotionSupport::Inflector.titleize(before))
    end
  end

  def test_camelize
    CamelToUnderscore.each do |camel, underscore|
      assert_equal(camel, MotionSupport::Inflector.camelize(underscore))
    end
  end

  def test_camelize_with_lower_downcases_the_first_letter
    assert_equal('capital', MotionSupport::Inflector.camelize('Capital', false))
  end

  def test_camelize_with_underscores
    assert_equal("CamelCase", MotionSupport::Inflector.camelize('Camel_Case'))
  end

  def test_acronyms
    MotionSupport::Inflector.inflections do |inflect|
      inflect.acronym("API")
      inflect.acronym("HTML")
      inflect.acronym("HTTP")
      inflect.acronym("RESTful")
      inflect.acronym("W3C")
      inflect.acronym("PhD")
      inflect.acronym("RoR")
      inflect.acronym("SSL")
    end

    #  camelize             underscore            humanize              titleize
    [
      ["API",               "api",                "API",                "API"],
      ["APIController",     "api_controller",     "API controller",     "API Controller"],
      ["Nokogiri::HTML",    "nokogiri/html",      "Nokogiri/HTML",      "Nokogiri/HTML"],
      ["HTTPAPI",           "http_api",           "HTTP API",           "HTTP API"],
      ["HTTP::Get",         "http/get",           "HTTP/get",           "HTTP/Get"],
      ["SSLError",          "ssl_error",          "SSL error",          "SSL Error"],
      ["RESTful",           "restful",            "RESTful",            "RESTful"],
      ["RESTfulController", "restful_controller", "RESTful controller", "RESTful Controller"],
      ["IHeartW3C",         "i_heart_w3c",        "I heart W3C",        "I Heart W3C"],
      ["PhDRequired",       "phd_required",       "PhD required",       "PhD Required"],
      ["IRoRU",             "i_ror_u",            "I RoR u",            "I RoR U"],
      ["RESTfulHTTPAPI",    "restful_http_api",   "RESTful HTTP API",   "RESTful HTTP API"],

      # misdirection
      ["Capistrano",        "capistrano",         "Capistrano",       "Capistrano"],
      ["CapiController",    "capi_controller",    "Capi controller",  "Capi Controller"],
      ["HttpsApis",         "https_apis",         "Https apis",       "Https Apis"],
      ["Html5",             "html5",              "Html5",            "Html5"],
      ["Restfully",         "restfully",          "Restfully",        "Restfully"],
      ["RoRails",           "ro_rails",           "Ro rails",         "Ro Rails"]
    ].each do |camel, under, human, title|
      assert_equal(camel, MotionSupport::Inflector.camelize(under))
      assert_equal(camel, MotionSupport::Inflector.camelize(camel))
      assert_equal(under, MotionSupport::Inflector.underscore(under))
      assert_equal(under, MotionSupport::Inflector.underscore(camel))
      assert_equal(title, MotionSupport::Inflector.titleize(under))
      assert_equal(title, MotionSupport::Inflector.titleize(camel))
      assert_equal(human, MotionSupport::Inflector.humanize(under))
    end
  end

  def test_acronym_override
    MotionSupport::Inflector.inflections do |inflect|
      inflect.acronym("API")
      inflect.acronym("LegacyApi")
    end

    assert_equal("LegacyApi", MotionSupport::Inflector.camelize("legacyapi"))
    assert_equal("LegacyAPI", MotionSupport::Inflector.camelize("legacy_api"))
    assert_equal("SomeLegacyApi", MotionSupport::Inflector.camelize("some_legacyapi"))
    assert_equal("Nonlegacyapi", MotionSupport::Inflector.camelize("nonlegacyapi"))
  end

  def test_acronyms_camelize_lower
    MotionSupport::Inflector.inflections do |inflect|
      inflect.acronym("API")
      inflect.acronym("HTML")
    end

    assert_equal("htmlAPI", MotionSupport::Inflector.camelize("html_api", false))
    assert_equal("htmlAPI", MotionSupport::Inflector.camelize("htmlAPI", false))
    assert_equal("htmlAPI", MotionSupport::Inflector.camelize("HTMLAPI", false))
  end

  def test_underscore_acronym_sequence
    MotionSupport::Inflector.inflections do |inflect|
      inflect.acronym("API")
      inflect.acronym("HTML5")
      inflect.acronym("HTML")
    end

    assert_equal("html5_html_api", MotionSupport::Inflector.underscore("HTML5HTMLAPI"))
  end

  def test_underscore
    CamelToUnderscore.each do |camel, underscore|
      assert_equal(underscore, MotionSupport::Inflector.underscore(camel))
    end
    CamelToUnderscoreWithoutReverse.each do |camel, underscore|
      assert_equal(underscore, MotionSupport::Inflector.underscore(camel))
    end
  end

  def test_camelize_with_module
    CamelWithModuleToUnderscoreWithSlash.each do |camel, underscore|
      assert_equal(camel, MotionSupport::Inflector.camelize(underscore))
    end
  end

  def test_underscore_with_slashes
    CamelWithModuleToUnderscoreWithSlash.each do |camel, underscore|
      assert_equal(underscore, MotionSupport::Inflector.underscore(camel))
    end
  end

  def test_demodulize
    assert_equal "Account", MotionSupport::Inflector.demodulize("MyApplication::Billing::Account")
    assert_equal "Account", MotionSupport::Inflector.demodulize("Account")
    assert_equal "", MotionSupport::Inflector.demodulize("")
  end

  def test_deconstantize
    assert_equal "MyApplication::Billing", MotionSupport::Inflector.deconstantize("MyApplication::Billing::Account")
    assert_equal "::MyApplication::Billing", MotionSupport::Inflector.deconstantize("::MyApplication::Billing::Account")

    assert_equal "MyApplication", MotionSupport::Inflector.deconstantize("MyApplication::Billing")
    assert_equal "::MyApplication", MotionSupport::Inflector.deconstantize("::MyApplication::Billing")

    assert_equal "", MotionSupport::Inflector.deconstantize("Account")
    assert_equal "", MotionSupport::Inflector.deconstantize("::Account")
    assert_equal "", MotionSupport::Inflector.deconstantize("")
  end

  def test_foreign_key
    ClassNameToForeignKeyWithUnderscore.each do |klass, foreign_key|
      assert_equal(foreign_key, MotionSupport::Inflector.foreign_key(klass))
    end

    ClassNameToForeignKeyWithoutUnderscore.each do |klass, foreign_key|
      assert_equal(foreign_key, MotionSupport::Inflector.foreign_key(klass, false))
    end
  end

  def test_tableize
    ClassNameToTableName.each do |class_name, table_name|
      assert_equal(table_name, MotionSupport::Inflector.tableize(class_name))
    end
  end

  def test_parameterize
    StringToParameterized.each do |some_string, parameterized_string|
      assert_equal(parameterized_string, MotionSupport::Inflector.parameterize(some_string))
    end
  end

  def test_parameterize_and_normalize
    StringToParameterizedAndNormalized.each do |some_string, parameterized_string|
      assert_equal(parameterized_string, MotionSupport::Inflector.parameterize(some_string))
    end
  end

  def test_parameterize_with_custom_separator
    StringToParameterizeWithUnderscore.each do |some_string, parameterized_string|
      assert_equal(parameterized_string, MotionSupport::Inflector.parameterize(some_string, '_'))
    end
  end

  def test_parameterize_with_multi_character_separator
    StringToParameterized.each do |some_string, parameterized_string|
      assert_equal(parameterized_string.gsub('-', '__sep__'), MotionSupport::Inflector.parameterize(some_string, '__sep__'))
    end
  end

  def test_classify
    ClassNameToTableName.each do |class_name, table_name|
      assert_equal(class_name, MotionSupport::Inflector.classify(table_name))
      assert_equal(class_name, MotionSupport::Inflector.classify("table_prefix." + table_name))
    end
  end

  def test_classify_with_symbol
    assert_nothing_raised do
      assert_equal 'FooBar', MotionSupport::Inflector.classify(:foo_bars)
    end
  end

  def test_classify_with_leading_schema_name
    assert_equal 'FooBar', MotionSupport::Inflector.classify('schema.foo_bar')
  end

  def test_humanize
    UnderscoreToHuman.each do |underscore, human|
      assert_equal(human, MotionSupport::Inflector.humanize(underscore))
    end
  end

  def test_humanize_by_rule
    MotionSupport::Inflector.inflections do |inflect|
      inflect.human(/_cnt$/i, '\1_count')
      inflect.human(/^prefx_/i, '\1')
    end
    assert_equal("Jargon count", MotionSupport::Inflector.humanize("jargon_cnt"))
    assert_equal("Request", MotionSupport::Inflector.humanize("prefx_request"))
  end

  def test_humanize_by_string
    MotionSupport::Inflector.inflections do |inflect|
      inflect.human("col_rpted_bugs", "Reported bugs")
    end
    assert_equal("Reported bugs", MotionSupport::Inflector.humanize("col_rpted_bugs"))
    assert_equal("Col rpted bugs", MotionSupport::Inflector.humanize("COL_rpted_bugs"))
  end

  def test_constantize
    run_constantize_tests_on do |string|
      MotionSupport::Inflector.constantize(string)
    end
  end

  def test_safe_constantize
    run_safe_constantize_tests_on do |string|
      MotionSupport::Inflector.safe_constantize(string)
    end
  end

  def test_ordinal
    OrdinalNumbers.each do |number, ordinalized|
      assert_equal(ordinalized, MotionSupport::Inflector.ordinalize(number))
    end
  end

  def test_dasherize
    UnderscoresToDashes.each do |underscored, dasherized|
      assert_equal(dasherized, MotionSupport::Inflector.dasherize(underscored))
    end
  end

  def test_underscore_as_reverse_of_dasherize
    UnderscoresToDashes.each do |underscored, dasherized|
      assert_equal(underscored, MotionSupport::Inflector.underscore(MotionSupport::Inflector.dasherize(underscored)))
    end
  end

  def test_underscore_to_lower_camel
    UnderscoreToLowerCamel.each do |underscored, lower_camel|
      assert_equal(lower_camel, MotionSupport::Inflector.camelize(underscored, false))
    end
  end

  def test_symbol_to_lower_camel
    SymbolToLowerCamel.each do |symbol, lower_camel|
      assert_equal(lower_camel, MotionSupport::Inflector.camelize(symbol, false))
    end
  end

  %w{plurals singulars uncountables humans}.each do |inflection_type|
    class_eval <<-RUBY, __FILE__, __LINE__ + 1
      def test_clear_#{inflection_type}
        cached_values = MotionSupport::Inflector.inflections.#{inflection_type}
        MotionSupport::Inflector.inflections.clear :#{inflection_type}
        assert MotionSupport::Inflector.inflections.#{inflection_type}.empty?, \"#{inflection_type} inflections should be empty after clear :#{inflection_type}\"
        MotionSupport::Inflector.inflections.instance_variable_set :@#{inflection_type}, cached_values
      end
    RUBY
  end

  def test_clear_all
    cached_values = MotionSupport::Inflector.inflections.plurals.dup, MotionSupport::Inflector.inflections.singulars.dup, MotionSupport::Inflector.inflections.uncountables.dup, MotionSupport::Inflector.inflections.humans.dup
    MotionSupport::Inflector.inflections do |inflect|
      # ensure any data is present
      inflect.plural(/(quiz)$/i, '\1zes')
      inflect.singular(/(database)s$/i, '\1')
      inflect.uncountable('series')
      inflect.human("col_rpted_bugs", "Reported bugs")

      inflect.clear :all

      assert inflect.plurals.empty?
      assert inflect.singulars.empty?
      assert inflect.uncountables.empty?
      assert inflect.humans.empty?
    end
    MotionSupport::Inflector.inflections.instance_variable_set :@plurals, cached_values[0]
    MotionSupport::Inflector.inflections.instance_variable_set :@singulars, cached_values[1]
    MotionSupport::Inflector.inflections.instance_variable_set :@uncountables, cached_values[2]
    MotionSupport::Inflector.inflections.instance_variable_set :@humans, cached_values[3]
  end

  def test_clear_with_default
    cached_values = MotionSupport::Inflector.inflections.plurals.dup, MotionSupport::Inflector.inflections.singulars.dup, MotionSupport::Inflector.inflections.uncountables.dup, MotionSupport::Inflector.inflections.humans.dup
    MotionSupport::Inflector.inflections do |inflect|
      # ensure any data is present
      inflect.plural(/(quiz)$/i, '\1zes')
      inflect.singular(/(database)s$/i, '\1')
      inflect.uncountable('series')
      inflect.human("col_rpted_bugs", "Reported bugs")

      inflect.clear

      assert inflect.plurals.empty?
      assert inflect.singulars.empty?
      assert inflect.uncountables.empty?
      assert inflect.humans.empty?
    end
    MotionSupport::Inflector.inflections.instance_variable_set :@plurals, cached_values[0]
    MotionSupport::Inflector.inflections.instance_variable_set :@singulars, cached_values[1]
    MotionSupport::Inflector.inflections.instance_variable_set :@uncountables, cached_values[2]
    MotionSupport::Inflector.inflections.instance_variable_set :@humans, cached_values[3]
  end

  Irregularities.each do |irregularity|
    singular, plural = *irregularity
    MotionSupport::Inflector.inflections do |inflect|
      define_method("test_irregularity_between_#{singular}_and_#{plural}") do
        inflect.irregular(singular, plural)
        assert_equal singular, MotionSupport::Inflector.singularize(plural)
        assert_equal plural, MotionSupport::Inflector.pluralize(singular)
      end
    end
  end

  Irregularities.each do |irregularity|
    singular, plural = *irregularity
    MotionSupport::Inflector.inflections do |inflect|
      define_method("test_pluralize_of_irregularity_#{plural}_should_be_the_same") do
        inflect.irregular(singular, plural)
        assert_equal plural, MotionSupport::Inflector.pluralize(plural)
      end
    end
  end

  [ :all, [] ].each do |scope|
    MotionSupport::Inflector.inflections do |inflect|
      define_method("test_clear_inflections_with_#{scope.kind_of?(Array) ? "no_arguments" : scope}") do
        # save all the inflections
        singulars, plurals, uncountables = inflect.singulars, inflect.plurals, inflect.uncountables

        # clear all the inflections
        inflect.clear(*scope)

        assert_equal [], inflect.singulars
        assert_equal [], inflect.plurals
        assert_equal [], inflect.uncountables

        # restore all the inflections
        singulars.reverse.each { |singular| inflect.singular(*singular) }
        plurals.reverse.each   { |plural|   inflect.plural(*plural) }
        inflect.uncountable(uncountables)

        assert_equal singulars, inflect.singulars
        assert_equal plurals, inflect.plurals
        assert_equal uncountables, inflect.uncountables
      end
    end
  end

  { :singulars => :singular, :plurals => :plural, :uncountables => :uncountable, :humans => :human }.each do |scope, method|
    MotionSupport::Inflector.inflections do |inflect|
      define_method("test_clear_inflections_with_#{scope}") do
        # save the inflections
        values = inflect.send(scope)

        # clear the inflections
        inflect.clear(scope)

        assert_equal [], inflect.send(scope)

        # restore the inflections
        if scope == :uncountables
          inflect.send(method, values)
        else
          values.reverse.each { |value| inflect.send(method, *value) }
        end

        assert_equal values, inflect.send(scope)
      end
    end
  end
end