module ApplicationHelper
  def number_to_currency_td(number)
    number_to_currency(number,format: "<td align=\"right\">%u</td><td align=\"right\">%n</td>", negative_format: "<td align=\"right\">- %u</td><td align=\"right\">%n</td>")
  end
end
