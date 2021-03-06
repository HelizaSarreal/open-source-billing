# dashboard related js code

# report data
jQuery ->

  # chart options
  if gon?
    chart_ticks = gon.chart_data["ticks"]

  chart_defaults =
    renderer: jQuery.jqplot.BarRenderer
    rendererOptions:
      fillToZero: true
      barWidth: 10
      barPadding: 5

  chart_series =  [
    label: "Billing"
    shadow: false
    color: '#00BDE5'
  ,
    label: "Paid Bills"
    shadow: false
    color: '#8EC42A'
  ]

  chart_legend = show: true, placement: "insideGrid"

  chart_xaxis =
    renderer: jQuery.jqplot.CategoryAxisRenderer
    ticks: chart_ticks
    tickOptions:
      showGridline: false


  chart_yaxis = pad: 0, tickOptions:
    formatString: "$%'i"
    showMark: false

  chart_axis =
    xaxis: chart_xaxis
    yaxis: chart_yaxis

  chart_grid =
    background: '#0000FF'
    drawBorder: false
    shadow: false
    borderWidth: 0.5

  chart_options =
    seriesDefaults: chart_defaults
    series: chart_series
    legend: chart_legend
    axes: chart_axis
    grid: chart_grid
    axesDefaults:
      rendererOptions:
        drawBaseline: false
    highlighter:
      show: true
      showMarker: false
      tooltipAxes: 'y'
      formatString: '<table class="jqplot-highlighter"><tr><td><b>%s</b></td></tr></table>'
      show:true
      showMarker:  false
#      sizeAdjust: 10
#      tooltipLocation: 'n'
#      tooltipAxes: 'x'
#      useAxesFormatters: true


  if gon?
    invoices = gon.chart_data["billing"]
    payments = gon.chart_data["payments"]
    chart_data = [billing, payments]

  try
    jQuery.jqplot "dashboard-chart", chart_data, chart_options
  catch e

  # show chart details when chart bar is clicked
  jQuery("#dashboard-chart").bind "jqplotDataClick", (ev, seriesIndex, pointIndex, data) ->
    chart_for =  if seriesIndex == 0 then 'billing' else 'payments'
    jQuery.ajax '/dashboard/chart_details',
                type: 'POST'
                data: "chart_date=#{chart_ticks[pointIndex]}&chart_for=#{chart_for}"
                dataType: 'html'
                error: (jqXHR, textStatus, errorThrown) ->
                  alert "Error: #{textStatus}"
                success: (data, textStatus, jqXHR) ->
                  jQuery("#chart_details.modal").show().find(".modal-body").html(data)
                    .find(".scrollContainer").mCustomScrollbar scrollInertia: 150
                  jQuery("html, body").animate({ scrollTop: 0 }, 600);

  # hide chart details popup when clicked outside it
  jQuery(document).click (e) ->
    container = jQuery("#chart_details")
    container.hide()  if container.has(e.target).length is 0 and container.is(':visible')

  jQuery('#chart_details .popup_close').click ->
    jQuery("#chart_details").hide()

