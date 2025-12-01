# Configure CORS for API access
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'  # In production, change this to specific domains
    
    resource '/api/*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: false,
      max_age: 600
  end
end
