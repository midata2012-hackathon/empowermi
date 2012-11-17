require 'rest-client'
require 'yajl'
require 'date'

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

$pds_data_sets = %w(field_ds_utility field_ds_personal_details field_ds_home)
$transaction_data_sets = %w(
  field_ds_bank_transactions
  field_ds_cc_transactions
  field_ds_journeys
  field_ds_loyalty_scheme
  field_ds_utility_data_usage
  field_ds_utility_meter_readings
  field_ds_utility_tel_calls
  field_ds_utility_billing
)

def pds_call(persona_id, data_sets)
  persona = $config[persona_id]
  base_uri = "https://sbx-api.mydex.org/api/pds/pds/#{persona[:uid]}.#{RESPONSE_FORMAT}"
  opts = {
    key: persona[:key],
    api_key: $config[:api_key],
    con_id: persona[:con_id],
    source_type: 'connection',
    dataset: data_sets.join(' ')

  }
  RestClient.get(base_uri, params: opts)
end

def transaction_call(persona_id, data_sets)
  persona = $config[persona_id]
  base_uri = "https://sbx-api.mydex.org/api/pds/transaction/#{persona[:uid]}.#{RESPONSE_FORMAT}"
  opts = { 
    key: persona[:transaction_key],
    api_key: $config[:api_key],
    dataset: data_sets
  }
  RestClient.get(base_uri, params: opts)
end

def pds_data(persona_id)
  @pds_data ||= {}
  @pds_data[persona_id] ||= begin
                   result = pds_call(persona_id, $pds_data_sets)
                   Yajl::Parser.parse(result)
                 end
end

def transaction_data(persona_id)
  @transaction_data ||= {}
  @transaction_data[persona_id] ||= begin
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

  def name
    personal = pds_data(@persona_id)['field_ds_personal_details'].values.first
    "#{get(personal, 'personal_fname')} #{get(personal, 'personal_faname')}"
  end

  def postcode
    home = pds_data(@persona_id)['field_ds_home'].values.first
    get(home, 'home_postcode')
  end

  def energy_bill
    bills = transaction_data(@persona_id)["field_ds_utility_billing"]
    bills = bills.find_all { |ut| ut['field_utility_service'].to_s =~ /(electricity|gas)/i }
    bills = bills.sort { |b1, b2| Date.strptime(b1['field_utility_billing_start'], '%m/%d/%Y') <=>  Date.strptime(b2['field_utility_billing_start'], '%m/%d/%Y') }
    bills[0..11].reduce(0) { |acc, bill| acc += bill['field_utility_billing_total'].to_f }
  end
end

