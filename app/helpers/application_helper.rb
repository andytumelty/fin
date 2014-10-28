module ApplicationHelper
  def number_to_currency_td(number, class_label)
    number_to_currency(
      number,
      format: ("<td align=\"right\"><span class=\"" + class_label + "_sign\"></span><span class=\"" + class_label + "_currency\">%u</span></td><td class=\"" + class_label + "_amount\" align=\"right\">%n</td>").html_safe, 
      negative_format: ("<td align=\"right\"><span class=\"" + class_label + "_sign\">-</span><span class=\"" + class_label + "_currency\">%u</span><td class=\"" + class_label + "_amount\" align=\"right\">%n</td>").html_safe )
  end
end
