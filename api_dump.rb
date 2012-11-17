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

def pds_call(persona, data_set)
  persona = $config[persona]
  base_uri = "https://sbx-api.mydex.org/api/pds/pds/#{persona[:uid]}.#{RESPONSE_FORMAT}"
  opts = {
    key: persona[:key],
    api_key: $config[:api_key],
    con_id: persona[:con_id],
    source_type: 'connection',
    dataset: data_set

  }
  RestClient.get(base_uri, params: opts)
end
