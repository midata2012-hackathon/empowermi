require 'rest-client'
require 'yajl'
require 'date'
require File.expand_path(File.join(File.dirname(__FILE__), 'recommendations'))

RESPONSE_FORMAT = 'json'
$config = {
  api_key: 'UUhZv3MitYy6g4afGXgmaQU40fdaSTQM',
  rbfish:{ uid: 97,
  key: 'HpFE4osh84cOn7BdYR7T24Eyf4vQB48i',
  con_id: '97-2156',
  transaction_key: 'Ooiajwd*811212j3o123' },

  jmsimpson: { uid: 98,
  key: 'OGCVFIzCLCIUjgqylu4gLLjNjqJ3Byzq',
  con_id: '98-2156',
  transaction_key: 'Duda123dgd811212j3o1' },

  adcassel: { uid: 99,
  key: 'EiHqhyAh6rC1Ah2ZJDWb5F1ada9tZ6cD',
  con_id: '99-2156',
  transaction_key: 'Oawd896811212123nf83' },

  aabutterworth: { uid: 100,
  key: 'IciXMKdJWBjwpoh3E01omPQBeC9jTKzB',
  con_id: 100-2156,
  transaction_key: '08mad7J*9898awdi2Hk3' },

  uepatten: { uid: 101,
  key: 'k9MyGAby0j3UaTvbOlK5Q7qHO9waAJZV',
  con_id: '101-2156',
  transaction_key: 'uyhdsjwdkuhap23j0dj0' },

  dbkingston: { uid: 102,
  key: 'IWyiBXesF89z40BFlulb01IS3Dpvnw26',
  con_id: '102-2156',
  transaction_key: '2doijawd94ilma888omd' },

  aehill: { uid: 103,
  key: 'iRenFn0gAXG6vyshQM1hDyofijicl73D',
  con_id: '103-2156',
  transaction_key: 'UhNudh781Nla47100087' },

  btnelston: { uid: 104,
  key: 'MszoM5NamQOmScJI3lXGugzePbbHKUkw',
  con_id: '104-2156',
  transaction_key: '786OjdaouYhwfd7m24Im' }
}

# $pds_data_sets = %w(field_ds_utility field_ds_personal_details field_ds_home)
# $transaction_data_sets = %w(
#   field_ds_bank_transactions
#   field_ds_cc_transactions
#   field_ds_journeys
#   field_ds_loyalty_scheme
#   field_ds_utility_data_usage
#   field_ds_utility_meter_readings
#   field_ds_utility_tel_calls
#   field_ds_utility_billing
# )
# 
$pds_data_sets = %w(field_ds_utility field_ds_personal_details field_ds_home)
$transaction_data_sets = %w(
  field_ds_utility_meter_readings
  field_ds_utility_tel_calls
  field_ds_utility_billing
)


def pds_call(persona_id, data_sets)
  persona = $config[persona_id]
  opts = {
    key: persona[:key],
    con_id: persona[:con_id],
    source_type: 'connection',
    dataset: data_sets.join(' ')
  }
  api_call('pds', persona, opts)
end

def transaction_call(persona_id, data_sets)
  persona = $config[persona_id]
  opts = { 
    key: persona[:transaction_key],
    dataset: data_sets
  }
  api_call('transaction', persona, opts)
end

def api_call(type, persona, opts = {})
  base_uri = "https://sbx-api.mydex.org/api/pds/#{type}/#{persona[:uid]}.#{RESPONSE_FORMAT}"
  defaults = { 
    api_key: $config[:api_key],
  }
  RestClient.get(base_uri, params: defaults.merge(opts))
end

def pds_data_cache(persona_id)
  @pds_data_cache ||= {}
  @pds_data_cache[persona_id] ||= begin
                   result = pds_call(persona_id, $pds_data_sets)
                   Yajl::Parser.parse(result)
                 end
end

def transaction_data_cache(persona_id)
  @transaction_data_cache ||= {}
  @transaction_data_cache[persona_id] ||= begin
                                      d = {}
                                      $transaction_data_sets.each do |data_set_name|
                                        result = transaction_call(persona_id, [data_set_name])
                                        d[data_set_name] = Yajl::Parser.parse(result)
                                      end
                                      d
                                    end

end

def get(response_hash, key, prefix = 'field_')
  key = "#{prefix}#{key}"
  response_hash[key]['value']
end

class Persona
  def initialize(persona_id)
    @persona_id = persona_id
  end
  
  def g(what, args = [], fallback = '')
    self.__send__(what, *args) rescue fallback
  end

  def name
    "#{get(personal, 'personal_fname')} #{get(personal, 'personal_faname')}"
  end

  def postcode
    get(home, 'home_postcode')
  end

  def property_type
    get(home, 'home_property_type')
  end

  def energy_bill
    bills = transaction_data_cache(@persona_id)["field_ds_utility_billing"]
    bills = bills.find_all { |ut| ut['field_utility_service'].to_s =~ /(electricity|gas)/i }
    bills = bills.sort { |b1, b2| Date.strptime(b1['field_utility_billing_start'], '%m/%d/%Y') <=>  Date.strptime(b2['field_utility_billing_start'], '%m/%d/%Y') }
    bills[0..11].reduce(0) { |acc, bill| acc += bill['field_utility_billing_total'].to_f }
  end

  private
  def home
    pds_data_cache(@persona_id)['field_ds_home'].values.first
  end

  def personal
    pds_data_cache(@persona_id)['field_ds_personal_details'].values.first
  end
end
#load 'api_dump.rb' ; p = Persona.new(:rbfish)
#

class ApiResponse
  class << self
    def response_template
      {
        name: '',
        postcode: '',
        spendings: [],
        recommendations: []
      }
    end
    
    def spending_template(cost, other = {})
      {
        id:   'energy-bill',
        name: 'Energy bill',
        cost: cost.to_f
      }.merge(other)
    end

    def recommendations_for(persona_id = :rbfish)
      template = response_template
      persona  = Persona.new(persona_id)
      
      template[:name]     = persona.g(:name)
      template[:postocde] = persona.g(:postcode)
      template[:spendings] << spending_template(persona.energy_bill)
      template[:recommendations] = $recommendations[persona.property_type.gsub(/\s+/,'').downcase]

      template
    end
  end
end
