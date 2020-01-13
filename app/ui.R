header <- dashboardHeader(
  title = "Model Demo"
)

sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem(text = "Initial Insight", tabName = "initInsight", icon = icon("chart-line"), startExpanded = TRUE,
      menuSubItem(text = "Transaction", tabName = "initTxnInsight"),
      menuSubItem(text = "First Transaction", tabName = "init1stOrderCohort"),
      menuSubItem(text = "Retention Analysis", tabName = "initRetentionInsight"),
      menuSubItem(text = "RFM", tabName = "initRfmInsight")
    ),
    menuItem(text = "CLV", tabName = "clvInsight", icon = icon("chart-line"), startExpanded = TRUE,
      menuSubItem(text = "Model Fitting", tabName = "clvModelFitting"),
      menuSubItem(text = "CLV Trend", tabName = "clvTrend"),
      menuSubItem(text = "CLV x First Transaction", tabName = "clv1stOrderCohort")
    )
  )
)

body <- dashboardBody(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "css/style.css")),
  tabItems(
    tabItem(tabName = "initTxnInsight", bootstrapPage(htmlTemplate(filename = "www/html/index.html", page = initTxnInsightUI("page1")))),
    tabItem(tabName = "init1stOrderCohort", bootstrapPage(htmlTemplate(filename = "www/html/index.html", page = init1stOrderCohortUI("page2")))),
    tabItem(tabName = "initRetentionInsight", bootstrapPage(htmlTemplate(filename = "www/html/index.html", page = initRetentionInsightUI("page3")))),
    tabItem(tabName = "initRfmInsight", bootstrapPage(htmlTemplate(filename = "www/html/index.html", page = initRfmInsightUI("page4")))),
    tabItem(tabName = "clvModelFitting", bootstrapPage(htmlTemplate(filename = "www/html/index.html", page = clvModelFittingUI("page5")))),
    tabItem(tabName = "clvTrend", bootstrapPage(htmlTemplate(filename = "www/html/index.html", page = clvTrendUI("page6")))),
    tabItem(tabName = "clv1stOrderCohort", bootstrapPage(htmlTemplate(filename = "www/html/index.html", page = clv1stOrderCohortUI("page7"))))
  )
)

ui <- dashboardPage(
  title = "Model Demo",
  skin = "blue",
  header = header,
  sidebar = sidebar,
  body = body
)