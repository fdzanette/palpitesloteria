require 'nokogiri'
require 'httparty'

class PagesController < ApplicationController
  def home
    url = "http://loterias.caixa.gov.br/wps/portal/loterias/landing/loteca/programacao"

    html_file = HTTParty.get(url)
    html_doc = Nokogiri::HTML(html_file)
    @jogos = html_doc.css('td')
    #@jogos.each do |jogo|

#    end
  end
end
