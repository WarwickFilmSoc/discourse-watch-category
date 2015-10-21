# name: Watch Category
# about: Watches a category for all the users in a particular group
# version: 0.2
# authors: Arpit Jalan, Thomas Purchas
# url: https://github.com/thomaspurchas/discourse-watch-category
enabled_site_setting :watching_enabled

module ::WatchCategory
  def self.watch_category!
    groups_cats = {
      "exec" => "exec",
      "exec" => "shadow-exec",
      "duty_managers" => "duty-managers",
      "q_proj" => "proj",
      "q_proj" => "show-reports",
      "t_proj" => "show-reports"
    }
    
    groups_cats.each do |group_name, cat_slug|
      category = Category.find_by_slug(cat_slug)
      group = Group.find_by_name(group_name)
      
      unless category.nil? || group.nil?
        group.users.each do |user|
          watched_categories = CategoryUser.lookup(user, :watching).pluck(:category_id)
          CategoryUser.set_notification_level_for_category(user, CategoryUser.notification_levels[:watching], category.id) unless watched_categories.include?(category.id)
        end
      end
    end
  end
end

after_initialize do
  module ::WatchCategory
    class WatchCategoryJob < ::Jobs::Scheduled
      every 1.day

      def execute(args)
        if SiteSetting.watching_enabled
          WatchCategory.watch_category!
        end
      end
    end
  end
end
