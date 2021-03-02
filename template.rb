require 'fileutils'
require 'shellwords'

OUTPUT_COLOR = :blue

# Copied from: https://github.com/mattbrictson/rails-template
# Add this template directory to source_paths so that Thor actions like
# copy_file and template resolve against our source files. If this file was
# invoked remotely via HTTP, that means the files are not present locally.
# In that case, use `git clone` to download them to a local temporary dir.
def add_template_repository_to_source_path
  if __FILE__ =~ %r{\Ahttps?://}
    require 'tmpdir'
    source_paths.unshift(tempdir = Dir.mktmpdir('jumpstart-rails-api-'))
    at_exit { FileUtils.remove_entry(tempdir) }
    git clone: [
      '--quiet',
      'https://github.com/beyode/jumpstart-rails-api.git',
      tempdir
    ].map(&:shellescape).join(' ')

    if (branch = __FILE__[%r{jumpstart-rails-api/(.+)/template.rb}, 1])
      Dir.chdir(tempdir) { git checkout: branch }
    end
  else
    source_paths.unshift(File.dirname(__FILE__))
  end
end

def install_taiwindcss
  # run "yarn add tailwindcss"
  run 'yarn add tailwindcss@yarn:@tailwindcss/postcss7-compat'
  run 'yarn add @tailwindcss/forms @tailwindcss/typography @tailwindcss/aspect-ratio'

  run 'mkdir app/javascript/stylesheets'
  run 'touch app/javascript/stylesheets/application.scss'

  inject_into_file 'app/javascript/stylesheets/application.scss' do
    <<~EOF
      @import "tailwindcss/base";
      @import "tailwindcss/components";
      @import "tailwindcss/utilities";
    EOF
  end

  run 'npx tailwindcss init'

  inject_into_file 'app/javascript/packs/application.js', after: 'import "channels"' do
    <<~EOF
      import "stylesheets/application.scss"
    EOF
  end

  inject_into_file 'postcss.config.js', before: "require('postcss-import')" do
    <<~EOF
      require('tailwindcss'),
      require('autoprefixer'),
    EOF
  end

  gsub_file 'tailwind.config.js', /purge:\s\[\],/, <<-PURGE
  purge: [
    './app/**/*.html.erb',
    './app/helpers/**/*.rb',
    './src/**/*.html',
    './src/**/*.js',
    './src/**/*.jsx',
  ],
  PURGE

  gsub_file 'tailwind.config.js', /plugins:\s\[\],/, <<-PLUGINS
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
    require('@tailwindcss/aspect-ratio'),
  ],
  PLUGINS

  inject_into_file 'app/views/layouts/application.html.erb',
                   before: "<%= javascript_pack_tag 'application', 'data-turbolinks-track': 'reload' %>" do
    <<~EOF
      <%= stylesheet_pack_tag 'application', media: 'all', 'data-turbolinks-track': 'reload' %>
    EOF
  end
end

def copy_templates
  directory 'lib', force: true
end

after_bundle do
  run 'spring stop'

  install_taiwindcss

  git :init
  git add: '.'

  begin
    git commit: %(-m "first commit")
  rescue StandardError => e
    puts e.message
  end

  say
  say 'Application generated sucessfully', OUTPUT_COLOR
  say
  say "cd #{app_name} to switch to app", OUTPUT_COLOR
end
