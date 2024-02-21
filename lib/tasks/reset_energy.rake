namespace :energy do
  desc 'Reset energy for all characters'
  task reset: :environment do
    Character.update_all(energy: Character.column_defaults['energy'])
  end
end
