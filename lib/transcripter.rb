require 'nokogiri'

class Transcripter
  HTML_XSLT = Nokogiri::XSLT(File.read(__dir__ + '/xslt/tei_to_html.xsl'))

  def self.from_tei(tei_xml)
    tei_doc = Nokogiri::XML(tei_xml)
    ugly_xml = HTML_XSLT.transform(tei_doc).to_xml
    Nokogiri::HTML(ugly_xml).to_xml
      .sub('<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" "http://www.w3.org/TR/REC-html40/loose.dtd">', '')
      .sub('<?xml version="1.0" encoding="utf-8"?><html><body>', '')
      .sub('xmlns:xhtml="http://www.w3.org/1999/xhtml"', '')
      .sub('</body></html>', '')
  end
end
