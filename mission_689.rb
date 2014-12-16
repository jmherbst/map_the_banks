require 'json'
require 'mechanize'
require 'turbotlib'
require 'pry'

INVESTMENT_FIRMS_SOURCE_URLS = [
  "http://www.hanfa.hr/EN/registar/2?&page=0",
  "http://www.hanfa.hr/EN/registar/2?&page=1"
]
BROKERS_SOURCE_URLS = [
  "http://www.hanfa.hr/EN/registar/18/brokeri?&page=0",
  "http://www.hanfa.hr/EN/registar/18/brokeri?&page=1",
  "http://www.hanfa.hr/EN/registar/18/brokeri?&page=2",
  "http://www.hanfa.hr/EN/registar/18/brokeri?&page=3",
  "http://www.hanfa.hr/EN/registar/18/brokeri?&page=4"
]
ADVISORS_SOURCE_URLS = [
  "http://www.hanfa.hr/EN/registar/19/investicijski-savjetnici?&page=0",
  "http://www.hanfa.hr/EN/registar/19/investicijski-savjetnici?&page=1",
  "http://www.hanfa.hr/EN/registar/19/investicijski-savjetnici?&page=2",
  "http://www.hanfa.hr/EN/registar/19/investicijski-savjetnici?&page=3"
]
TIED_AGENTS_SOURCE_URLS = [
  "http://www.hanfa.hr/EN/registar/3"
]
                
def gather_investment_firms(urls)
  urls.each do |url|
    doc = @agent.get(url).parser

    doc.css('.body-row').each do |row|

      name = row.css('.span-17').children.css('span').text.strip
      oib = row.css('.span-2').text.gsub("OIB","").strip

      # Details for this Firm 
      first_col = row.css('.switchable-content').css('.column').css('.first')
      second_col = row.css('.switchable-content').css('.column')[1]
      
      # Gather first column
      general_data_info = first_col.css('ul')[0]

      # Sometimes BIC isn't there... 
      if first_col.css('ul').length > 1
        bic_info = first_col.css('ul')[1] 
        bic = bic_info.css('li').text
      else
        bic = "NO BIC"
      end
    
      general_data_details = general_data_info.css('li').map {|d| d.text}
      
      address = general_data_details[0].gsub("Address","").strip
      phone = general_data_details[1].gsub("Phone","").strip
      website = general_data_details[2].gsub("Website","").strip
      approved_activities = second_col.css('ul')[0].css('li').text
      court_reg_url = second_col.css('ul')[1].css('li').xpath('a/@href').first.value
      
      datum = {
        Name: name,
        OIB: oib,
        Address: address,
        Phone: phone,
        Website: website,
        BIC: bic,
        Approved_Activities: approved_activities,
        Court_Registrar_URL: court_reg_url,
        source_url: url,     # mandatory field
        sample_date: Time.now       # mandatory field
      }  

      puts JSON.dump(datum)
    end
  end
end

def gather_brokers(urls)
  urls.each do |url|
    doc = @agent.get(url).parser

    doc.css('.body-row').each do |row|
      cols = row.css('span').map {|r| r.children[2]}


      datum = {
        Name: cols[1].text.strip,
        Surname: cols[3].text.strip,
        RBS: cols[5].text.strip,
        Date_of_Decision: cols[7].text.strip,
        Firm: cols[9].text.strip,
        source_url: url,     # mandatory field
        sample_date: Time.now       # mandatory field
      }  

      puts JSON.dump(datum)
    end
    sleep(15)  # Sleeps loop for 15 seconds to avoid being denied with a 403
  end
end

@agent = Mechanize.new
@agent.robots = false

Turbotlib.log("Starting scrape...") # optional debug logging

gather_investment_firms(INVESTMENT_FIRMS_SOURCE_URLS)
gather_brokers(BROKERS_SOURCE_URLS)
