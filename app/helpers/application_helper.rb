module ApplicationHelper
  
  # Sets the page title and outputs title if container is passed in.
  # eg. <%= title('Hello World', :h2) %> will return the following:
  # <h2>Hello World</h2> as well as setting the page title.
  def title(str, container = nil)
    @page_title = str
    content_tag(container, str) if container
  end
  
  # Outputs the corresponding flash message if any are set
  def flash_messages
    messages = []
    %w(notice warning error).each do |msg|
      messages << content_tag(:div, html_escape(flash[msg.to_sym]), :id => "flash-#{msg}") unless flash[msg.to_sym].blank?
    end
    messages
  end

  def protect_link(rolename, text, controller, action="index")
    if current_user.has_role?(rolename)
      link_to_unless_current( text, :id => nil,
                                     :controller => controller,
                                     :action => action)
    end
  end

  def locale_link(locale, locale_desc)
     locale_text = "#{locale_desc} (#{locale})"
     options =  { :locale => "#{locale}" }
     if I18n.locale == locale
       "#{locale_desc} (#{locale})"
     else
       link_to locale_text,
       url_for( {:controller => self.controller_name, :action => self.action_name}.merge(options) )
     end
  end

end
