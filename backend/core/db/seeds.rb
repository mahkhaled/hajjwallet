# Loads seed data out of default dir
default_path = File.join(File.dirname(__FILE__), 'default')

Rake::Task['db:load_dir'].reenable
Rake::Task['db:load_dir'].invoke(default_path)

Rake::Task['db:load_recommendations'].reenable
Rake::Task['db:load_recommendations'].invoke(default_path)
