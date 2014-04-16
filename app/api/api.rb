class API < Grape::API
  version :v1, using: :header, vendor: :shapter
  mount Shapter::Ping
end
