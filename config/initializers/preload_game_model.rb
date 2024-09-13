# https://guides.rubyonrails.org/autoloading_and_reloading_constants.html#option-3-preload-a-regular-directory

unless Rails.application.config.eager_load
  Rails.application.config.to_prepare do
    Rails.autoloaders.main.eager_load_dir(Rails.root.join("app/models/cards"))
  end
end
