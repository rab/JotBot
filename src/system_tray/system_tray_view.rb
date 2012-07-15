unless should_use_java16_jdic?
  include_class 'org.jdesktop.jdic.tray.TrayIcon'
  include_class 'org.jdesktop.jdic.tray.SystemTray'
end


include_class "javax.swing.JPopupMenu"
include_class "javax.swing.JMenu"
include_class "javax.swing.JMenuItem"
include_class "javax.swing.ImageIcon"

class SystemTrayView < ApplicationView
  attr_accessor :view_logs_menu_item, :log_now_menu_item, :report_menu_item, :options_menu_item, :exit_menu_item, :next_update_menu_item, :category_editor_menu_item, :license_key_menu_item, :about_menu_item, :help_menu_item, :register_menu_item

  map :view => "next_update_menu_item.text", :model => :next_update_text

  def create_main_view_component
    "Fake!"
  end


  def create_native_components


    menu = java.awt.PopupMenu.new("JotBot")
    @next_update_menu_item = java.awt.MenuItem.new("Next Update at:", nil)
    def @next_update_menu_item.text=(s)
      self.label = s
    end
    def @next_update_menu_item.text
      self.label
    end


    @next_update_menu_item.enabled = false
    menu.add(@next_update_menu_item)
    menu.addSeparator
    @log_now_menu_item = java.awt.MenuItem.new("Custom log entry", java.awt.MenuShortcut.new(Monkeybars::Key.symbol_to_code(:VK_L)))
    @log_now_menu_item.name = "log_now_menu_item"
    menu.add(@log_now_menu_item)
    @view_logs_menu_item = java.awt.MenuItem.new("View Logs", java.awt.MenuShortcut.new(Monkeybars::Key.symbol_to_code(:VK_V)))
    @view_logs_menu_item.name = "view_logs_menu_item"
    menu.add(@view_logs_menu_item)
    @report_menu_item = java.awt.MenuItem.new("Generate a report", java.awt.MenuShortcut.new(Monkeybars::Key.symbol_to_code(:VK_R)))
    @report_menu_item.name = "report_menu_item"
    menu.add(@report_menu_item)
    menu.addSeparator
    #settings = java.awt.MenuItem.new("Settings", java.awt.MenuShortcut.new(Monkeybars::Key.symbol_to_code(:VK_S)))
    settings = java.awt.Menu.new("Settings")
    menu.add(settings)
    @options_menu_item = java.awt.MenuItem.new("Options", java.awt.MenuShortcut.new(Monkeybars::Key.symbol_to_code(:VK_O)))
    @options_menu_item.name = "options_menu_item"
    settings.add(@options_menu_item)
    @category_editor_menu_item = java.awt.MenuItem.new("Category Editor", java.awt.MenuShortcut.new(Monkeybars::Key.symbol_to_code(:VK_C)))
    @category_editor_menu_item.name = "category_editor_menu_item"
    settings.add(@category_editor_menu_item)

    @help_menu_item = java.awt.MenuItem.new("Help", java.awt.MenuShortcut.new(Monkeybars::Key.symbol_to_code(:VK_H)))
    @help_menu_item.name = "help_menu_item"
    menu.add(@help_menu_item)

    if ( !LicenseManager.instance.valid_license_file?(Configuration.license_key_file) ) || LicenseManager.instance.license_can_expire?
      @register_menu_item = java.awt.MenuItem.new("Register JotBot", java.awt.MenuShortcut.new(Monkeybars::Key.symbol_to_code(:VK_B)))
      @register_menu_item.name = "register_menu_item"
      menu.add(@register_menu_item)
    end

    if Configuration.on_osx? && !Platform.is_java_64bit?
      menu.add(javax.swing.JSeparator.new)
      @exit_menu_item = java.awt.MenuItem.new("Quit", java.awt.MenuShortcut.new(Monkeybars::Key.symbol_to_code(:VK_Q)))
    else
      @about_menu_item = java.awt.MenuItem.new("About", java.awt.MenuShortcut.new(Monkeybars::Key.symbol_to_code(:VK_A)))
      @about_menu_item.name = "about_menu_item"
      menu.add(@about_menu_item)
      menu.addSeparator
      @exit_menu_item = java.awt.MenuItem.new("Exit", java.awt.MenuShortcut.new(Monkeybars::Key.symbol_to_code(:VK_X)))
    end

    @exit_menu_item.name = "exit_menu_item"
    menu.add(@exit_menu_item)


    if Configuration.on_linux?
      url = Java::org::rubyforge::rawr::Main.get_resource('images/jb_clock_icon_22x22.png')
    else
      url = Java::org::rubyforge::rawr::Main.get_resource('images/jb_clock_icon_16x16.png')
    end

    # http://www.igniterealtime.org/community/message/146529
    @tray = java.awt.SystemTray.system_tray
    # @tray.always_on_top = true  # Doesn't seemt o matter on Windows, where a problem was reported JGB
    tray_icon = java.awt.TrayIcon.new(ImageIcon.new(url).getImage, "JotBot", menu)
    @tray.add tray_icon 

  end

  def create_external_components

    menu = JPopupMenu.new("JotBot")
    @next_update_menu_item = JMenuItem.new("Next Update at:", nil)
    @next_update_menu_item.enabled = false
    menu.add(@next_update_menu_item)
    menu.add(javax.swing.JSeparator.new)
    @log_now_menu_item = JMenuItem.new("Custom log entry", Monkeybars::Key.symbol_to_code(:VK_L))
    @log_now_menu_item.name = "log_now_menu_item"
    menu.add(@log_now_menu_item)
    @view_logs_menu_item = JMenuItem.new("View Logs", Monkeybars::Key.symbol_to_code(:VK_V))
    @view_logs_menu_item.name = "view_logs_menu_item"
    menu.add(@view_logs_menu_item)
    @report_menu_item = JMenuItem.new("Generate a report", Monkeybars::Key.symbol_to_code(:VK_R))
    @report_menu_item.name = "report_menu_item"
    menu.add(@report_menu_item)
    menu.add(javax.swing.JSeparator.new)
    settings = JMenu.new("Settings")
    settings.mnemonic  = Monkeybars::Key.symbol_to_code(:VK_S)
    menu.add(settings)
    @options_menu_item = JMenuItem.new("Options", Monkeybars::Key.symbol_to_code(:VK_O))
    @options_menu_item.name = "options_menu_item"
    settings.add(@options_menu_item)
    @category_editor_menu_item = JMenuItem.new("Category Editor", Monkeybars::Key.symbol_to_code(:VK_C))
    @category_editor_menu_item.name = "category_editor_menu_item"
    settings.add(@category_editor_menu_item)

    @help_menu_item = JMenuItem.new("Help", Monkeybars::Key.symbol_to_code(:VK_H))
    @help_menu_item.name = "help_menu_item"
    menu.add(@help_menu_item)

    if ( !LicenseManager.instance.valid_license_file?(Configuration.license_key_file) ) || LicenseManager.instance.license_can_expire?
      @register_menu_item = JMenuItem.new("Register JotBot", Monkeybars::Key.symbol_to_code(:VK_B))
      @register_menu_item.name = "register_menu_item"
      menu.add(@register_menu_item)
    end

    if Configuration.on_osx? && !Platform.is_java_64bit? # NEW
      menu.add(javax.swing.JSeparator.new)
      @exit_menu_item = JMenuItem.new("Quit", Monkeybars::Key.symbol_to_code(:VK_Q))
    else
      @about_menu_item = JMenuItem.new("About", Monkeybars::Key.symbol_to_code(:VK_A))
      @about_menu_item.name = "about_menu_item"
      menu.add(@about_menu_item)
      menu.add(javax.swing.JSeparator.new)
      @exit_menu_item = JMenuItem.new("Exit", Monkeybars::Key.symbol_to_code(:VK_X))
    end

    @exit_menu_item.name = "exit_menu_item"
    menu.add(@exit_menu_item)


    if Configuration.on_linux?
      url = Java::org::rubyforge::rawr::Main.get_resource('images/jb_clock_icon_22x22.png')
    else
      url = Java::org::rubyforge::rawr::Main.get_resource('images/jb_clock_icon_16x16.png')
    end

    @tray = SystemTray.default_system_tray
    tray_icon = TrayIcon.new(ImageIcon.new(url), "JotBot", menu)
    @tray.add_tray_icon tray_icon

  end

  def load
    @main_view_component = self
    # There are some behavioral issues with Java 1.6 64bit when using jdic, so
    # when needed we'll use the desktop stuff built-in if need be.
    should_use_java16_jdic? ? create_native_components : create_external_components


  end

  def show; end
  def dispose; end
end
