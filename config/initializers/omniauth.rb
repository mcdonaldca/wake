

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :fitbit, '33a270b7f4c947d7bc55190efbce9386', 'e21d95d6d6144bf48e1a4252eb0a38be'
end