require "rubygems"
require "selenium-webdriver"
require "json"
require "yaml"

class Navigation
   
def initialize(brand)
   #@h=Headless.new
   #@h.start
   #Selenium::WebDriver::Firefox.path = "/usr/bin/firefox2"
   #driver= Selenium::WebDriver.for(:remote,:url =>"http://127.0.0.1:4444/wd/hub")
   driver= Selenium::WebDriver.for :firefox
   self.instance_variable_set("@browser", driver)  
   self.class.send(:define_method, 'browser', proc{self.instance_variable_get("@browser")})
   @VERBOSE=false
   @app_elements= YAML::load(File.open('app_elements.yml')) 
   @config=YAML::load(File.open('config.yml')) 
   @brand=decide_brand(brand)
   build_random_data()

   build_flow()
   kick_off_navigation()
end


def decide_brand(brand)
  @brand=brand
end

def build_url()
  @url=@config[@brand]["url_prefix"]+"manoj.qa.cashnetusa.com"+@config[@brand]["url_suffix"]
end

def build_flow
  build_url
  browser.navigate.to @url
end

def kick_off_navigation
  flow_hash=@config["#{@brand}"]["flows"]["ddi"]
  flow_hash.each do |k|
     form=@app_elements["#{k}"]
     t=Time.now
     fill_and_submit_form(form)
     puts "\e[32m#{k} took #{Time.now-t} seconds\e[0m"
  end
end

def get_data(element_array)
   case element_array.size
   when 4
        value=@user_input_hash["#{element_array[1]}"] || element_array[2]
        value.to_s
   when 3
        value=@random_hash["#{element_array[1]}"] || @user_input_hash["#{element_array[1]}"] || @defaults["#{element_array[1]}"]
        value.to_s
   else
       value=nil
   end
end

def findElement(e)
    begin
      element=browser.find_element(:id, e)
    rescue Selenium::WebDriver::Error::NoSuchElementError
      begin
        element=browser.find_element(:name, e)
      rescue Selenium::WebDriver::Error::NoSuchElementError 
        begin
          element=browser.find_element(:link, e)
        rescue Selenium::WebDriver::Error::NoSuchElementError 
          element=nil
          puts "\e[33m NOT ON PAGE: #{e} \e[0m" if @VERBOSE
        end
      end
    end
end

def fill_and_submit_form(form_array) 
   t=Time.now if @VERBOSE
   element=nil
   form_array.each do |v|
    element=findElement(v[0])
    if element
    case v[v.size-1] 
    when "type"
       data=get_data(v)
       element.clear
       element.send_keys(data)
       puts "\e[32m #{v[v.size-1]}    #{data} for #{v[1]} =>#{v[0]}\e[0m" if @VERBOSE
    when "select"
      data=get_data(v)
      option = element.find_elements(:tag_name => "option").find { |o| o.text.to_s.downcase[data.downcase]==data.downcase }
      option.click
      puts "\e[32m #{v[v.size-1]} #{data} for #{v[1]} =>#{v[0]}\e[0m" if @VERBOSE
    when "click"
      element.click if !element.selected?
      puts "\e[32m #{v[v.size-1]} on #{v[0]}\e[0m" if @VERBOSE
    when "submit"
      element.submit
      puts "\e[32m #{v[v.size-1]} #{v[0]}\e[0m" if @VERBOSE
    else
      puts "\e[31m  Unknown action :#{v[v.size-1]} for Element:#{v[0]}  \e[0m"
    end
   end
 end
  puts "\e[32m Time elapsed: #{Time.now-t} \e[0m" if @VERBOSE
end


def pay_freq_offset (user_input)
  
  if !user_input
    return 14
  end
  
  case user_input
  when "biweekly"
    return 14
  when "weekly"
    return 7
  when "four_weekly"
    return 28
  when "twice_monthly"
    return 15
  else 
    return 14
  end
end

def build_random_data()
  @random_hash={}
  @user_input_hash={}
  @defaults=@config["#{@brand}"]["default_data"]
  months=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
  t=Time.now
  four=(71-t.min).to_s + (71-t.sec).to_s
  @random_hash.store("four",four)

  d=Date.today+7
   
  income_freq_cd=@user_input_hash['income_freq_cd'] || @defaults["income_freq_cd"]
  @random_hash.store("income_freq_cd",income_freq_cd)

  pday1= d.day
  pmonth1=months[d.month-1]
  pyear1=d.year
  @random_hash.store("pday1",pday1)  
  @random_hash.store("pmonth1",pmonth1)
  @random_hash.store("pyear1",pyear1)
  
  d+=pay_freq_offset(income_freq_cd)
  pday2=d.day
  pmonth2=months[d.month-1]
  pyear2=d.year
  @random_hash.store("pday2",pday2)  
  @random_hash.store("pmonth2",pmonth2)
  @random_hash.store("pyear2",pyear2)
 
  check_number="2012"+four
  @random_hash.store("check_number",check_number)

  d=Date.today+7
  
  check_date = d.day
  check_month= months[d.month-1]
  check_year= d.year
  @random_hash.store("check_date",check_date)
  @random_hash.store("check_month",check_month)
  @random_hash.store("check_year",check_year)
  @random_hash.store("to_date",check_date)
  @random_hash.store("to_month",check_month)
  @random_hash.store("to_year",check_year)


  d-=pay_freq_offset(income_freq_cd)
  from_date=d.day
  from_month=months[d.month-1]
  from_year=d.year
  @random_hash.store("from_date",from_date)
  @random_hash.store("from_month",from_month)
  @random_hash.store("from_year",from_year)

  lname= @user_input_hash['lname'] ||"Test"+four
  email="cnu_"+four+"@cnuapptest.com"
  ssn="33322"+four
  ssn4=four
  @random_hash.store("lname",lname)
  @random_hash.store("fname","Test")
  @random_hash.store("email",email)
  @random_hash.store("ssn",ssn)
  @random_hash.store("ssn4",ssn4)

  home_phone=@defaults['phone_prefix']+"1"+four
  mobile_phone=@defaults['phone_prefix']+"2"+four
  work_phone=@defaults['phone_prefix']+"3"+four
  main_phone=@defaults['phone_prefix']+"4"+four
  @random_hash.store("home_phone",home_phone)
  @random_hash.store("mobile_phone",mobile_phone)
  @random_hash.store("work_phone",work_phone)
  @random_hash.store("main_phone",main_phone)

  stateid_num="24242"+four
  @random_hash.store("stateid_num",stateid_num)
  
  bank_account="2010"+four
  @random_hash.store("bank_account",bank_account)
end

def get_user_inputs()
  {}
end

def quit()
	browser.quit
	#@h.destroy
end

end
