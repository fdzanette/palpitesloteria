require 'nokogiri'
require 'httparty'

class PagesController < ApplicationController
  def home
    url = "http://loterias.caixa.gov.br/wps/portal/loterias/landing/loteca/programacao"

    html_file = HTTParty.get(url)
    html_doc = Nokogiri::HTML(html_file)
    @times = []
    @jogos = html_doc.css('tbody').text
    @jogos.split.each do |jogo|
      if jogo.length > 3 && jogo != "Sábado" && jogo != "Domingo"
        @times << jogo
      end
    end
  end
end
