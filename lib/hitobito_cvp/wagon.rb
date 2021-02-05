# encoding: utf-8
# frozen_string_literal: true

#  Copyright (c) 2012-2020, CVP Schweiz. This file is part of
#  hitobito_cvp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_cvp.


module HitobitoCvp
  class Wagon < Rails::Engine
    include Wagons::Wagon

    # Set the required application version.
    app_requirement '>= 0'

    # Add a load path for this specific wagon
    config.autoload_paths += %W[ #{config.root}/app/abilities
                                 #{config.root}/app/domain
                                 #{config.root}/app/jobs ]

    config.to_prepare do
      # extend application classes here
      Group.send        :include, Cvp::Group
      Role.send         :include, Cvp::Role
      Person.send       :include, Cvp::Person

      RoleDecorator.send :prepend, Cvp::RoleDecorator
      GroupDecorator.send :prepend, Cvp::GroupDecorator
      # rubocop:enable SingleSpaceBeforeFirstArg
      Event.role_types -= [Event::Role::Cook]

      PeopleController.send :prepend, Cvp::PeopleController
      FilterNavigation::People.send :prepend, Cvp::FilterNavigation::People

      Export::Pdf::Messages::Letter::Content.placeholders << :salutation
      Export::Pdf::Messages::Letter::Content.send :prepend,
                                                  Cvp::Export::Pdf::Messages::Letter::Content
      ## Customizations for migration
      Group.all_types.each do |type|
        # next if type.layer?
        unless type.const_defined?("#{type}::Merkmal")
          merkmal = Class.new(Role)
          type.const_set('Merkmal', merkmal)
          type.role_types += [merkmal]
        end
      end
    end

    initializer 'cvp.add_settings' do |_app|
      Settings.add_source!(File.join(paths['config'].existent, 'settings.yml'))
      Settings.reload!
    end

    initializer 'cvp.add_inflections' do |_app|
      ActiveSupport::Inflector.inflections do |inflect|
        # inflect.irregular 'census', 'censuses'
      end
    end

    private

    def seed_fixtures
      fixtures = root.join('db', 'seeds')
      ENV['NO_ENV'] ? [fixtures] : [fixtures, File.join(fixtures, Rails.env)]
    end

  end
end
