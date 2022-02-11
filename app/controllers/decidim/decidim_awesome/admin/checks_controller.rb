# frozen_string_literal: true

require "decidim/decidim_awesome/version"

module Decidim
  module DecidimAwesome
    module Admin
      # System compatibility analyzer
      class ChecksController < DecidimAwesome::Admin::ApplicationController
        include NeedsAwesomeConfig
        helper ConfigConstraintsHelpers
        helper SystemCheckerHelpers

        layout "decidim/admin/decidim_awesome"

        helper_method :head, :admin_head, :head_addons, :admin_addons

        def migrate_images
          Decidim::DecidimAwesome::MigrateLegacyImagesJob.perform_later(current_organization.id)
          flash[:notice] = I18n.t("image_migrations_started", scope: "decidim.decidim_awesome.admin.checks.index")
          redirect_to checks_path
        end

        private

        def head
          @head ||= Nokogiri::HTML(render_to_string(partial: "layouts/decidim/head"))
        end

        def admin_head
          @admin_head = Nokogiri::HTML(render_to_string(partial: "layouts/decidim/admin/header"))
        end

        def head_addons(part)
          case part
          when :CSS
            ['<%= stylesheet_pack_tag "decidim_decidim_awesome", media: "all" %>',
             '<%= render(partial: "layouts/decidim/decidim_awesome/custom_styles") if awesome_custom_styles %>'].join("\n")
          when :JavaScript
            ['<%= render partial: "layouts/decidim/decidim_awesome/awesome_config" %>',
             '<%= javascript_pack_tag "decidim_decidim_awesome" %>',
             '<%= javascript_pack_tag "decidim_decidim_awesome_custom_fields" if awesome_proposal_custom_fields %>'].join("\n")
          end
        end

        def admin_addons(part)
          case part
          when :CSS
            '<%= stylesheet_pack_tag "decidim_admin_decidim_awesome", media: "all" %>'
          when :JavaScript
            ['<%= javascript_pack_tag "decidim_admin_decidim_awesome", defer: false %>',
             '<%= javascript_pack_tag "decidim_decidim_awesome_custom_fields" if awesome_proposal_custom_fields %>'].join("\n")
          end
        end
      end
    end
  end
end
