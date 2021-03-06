module AdminMenuHelper
  def admin_menus
    {
      # "Menu #1": {
      #   submenu: {
      #     "Submenu #1": { url: url_for(q: 123), match: /q=123/ },
      #     "Submenu #2": { url: url_for(q: 456), match: /q=456/ }
      #   },
      #   icon: "star"
      # },
      # "Menu #2" => { url: url_for(q: 789), icon: "pencil", match: /q=789/ },
      '用戶管理': {
        submenu: {
          '後台使用者管理': { url: admin_users_path, match: /\/admin\/users/ },
          '觀察員管理': { url: admin_observers_path, match: /\/admin\/observers/ },
          '當事人管理': { url: admin_parties_path, match: /\/admin\/parties/ },
          '律師管理': { url: admin_lawyers_path, match: /\/admin\/lawyers/ }
        }
      },
      '法官管理': { url: admin_judges_path, match: /\/admin\/judges/ },
      '檢察官管理': { url: admin_prosecutors_path, match: /\/admin\/prosecutors/ },
      '法院管理': { url: admin_courts_path, match: /\/admin\/courts/ },
      '檢察署管理': { url: admin_prosecutors_offices_path, match: /\/admin\/prosecutors_offices/ },
      '庭期表管理': { url: admin_schedules_path, match: /\/admin\/schedules/ },
      '案件管理': { url: admin_stories_path, match: /\/admin\/stories/ },
      '裁判書管理': {
        submenu: {
          '判決管理': { url: admin_verdicts_path, match: /\/admin\/verdicts/ },
          '裁定管理': { url: admin_rules_path, match: /\/admin\/rules/ }
        }
      },
      '評鑑紀錄管理': {
        submenu: {
          '一般評鑑紀錄': { url: admin_scores_path, match: /\/admin\/scores/ },
          '有效評鑑紀錄': { url: admin_valid_scores_path, match: /\/admin\/valid_scores/ }
        }
      },
      '首頁橫幅管理': { url: admin_banners_path, match: /\/admin\/banners/ },
      '公告訊息管理': { url: admin_bulletins_path, match: /\/admin\/bulletins/ },
      '爬蟲紀錄': {
        submenu: {
          '每日爬蟲紀錄': { url: admin_crawler_histories_path, match: /\/admin\/crawler_histories/ },
          '裁判書抓取數據': { url: status_admin_crawler_histories_path, match: /\/admin\/crawler_histories\/status/ },
          '最高法院法官數據': { url: highest_judges_admin_crawler_histories_path, match: /\/admin\/crawler_histories\/status/ }
        }
      }
    }
  end

  def render_admin_menu(menus = nil)
    menus ||= admin_menus
    content_tag(:ul) do
      html = []
      menus.each do |label, item|
        html << render_admin_menu_item(label, item)
      end
      safe_join(html, '')
    end
  end

  private

  def render_admin_menu_item(label, item)
    html = []
    html << link_to(item[:submenu] ? '#' : item[:url]) do
      tmp = []
      tmp << content_tag(:i, class: "icon icon-#{item[:icon]}") { '' } if item[:icon]
      tmp << label
      safe_join(tmp, '')
    end
    html << render_admin_menu(item[:submenu]) if item[:submenu]
    actived = item[:match] ? request.original_url =~ item[:match] : false
    content_tag(:li, class: "#{item[:submenu] ? 'submenu ' : ''}#{actived ? 'active open' : ''}") do
      safe_join(html, '')
    end
  end
end
