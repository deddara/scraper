require 'nokogiri'
require 'httparty'
require 'byebug'



def scraper
  url = "https://ru.indeed.com/jobs-in-%D0%9A%D0%B0%D0%B7%D0%B0%D0%BD%D1%8C"
  unparsed_page = HTTParty.get(url)
  jobs = Array.new
  parsed_page = Nokogiri::HTML(unparsed_page)
  job_listings = parsed_page.css("div.jobsearch-SerpJobCard") #15 jobsearch

  page = 10
  per_page = job_listings.count
  total = parsed_page.css('div#searchCountPages').text.split(' ')[3].gsub(/\u00a0/, '').to_i
  last_page  =  (((total.to_f / per_page.to_f).round) -1 )*10

  while page<=last_page
      pagination_url = "https://ru.indeed.com/jobs?q=&l=%D0%9A%D0%B0%D0%B7%D0%B0%D0%BD%D1%8C&start=#{page}"
      puts pagination_url
      puts "Page: #{page}"
      puts ""
      pagination_unparsed_page = HTTParty.get(pagination_url)
      pagination_parsed_page = Nokogiri::HTML(pagination_unparsed_page)
      pagination_job_listings =  pagination_parsed_page.css("div.jobsearch-SerpJobCard")
      pagination_job_listings.each do |job_listing|
        job = {
          title: job_listing.css('div.title').text,
          company: job_listing.css('span.company').text,
          location: job_listing.css('div.location').text,
          description: job_listing.css('div.summary').text,
          url: "https://ru.indeed.com" + job_listing.css('a')[0].attributes["href"].value
        }


        jobs << job
        puts "added #{job[:title]}"
        puts ""
      end
    page +=10
  end
byebug
end


scraper
