# module ui
clvModelFittingUI <- function(id) {
  # set namespace via id
  ns <- NS(id)
  tagList(
    fluidRow(div(column(width = 4, h4("Transaction Parameter")), style = "color: #ffffff")),
    fluidRow(div(
      column(width = 3, dateRangeInput(inputId = ns("dateRange"), label = "Date Range", start = min(order.table$txn.date), end = max(order.table$txn.date))),
      column(width = 3, sliderInput(inputId = ns("avgTicketRange"), label = "Average Transaction Value Range", min = 0, max = max(order.table$txn.amount), value = c(1,max(order.table$txn.amount)/2))),
      column(width = 3, numericInput(inputId = ns("maxRepurchase"), label = "Maximum Repurchase Times", value = n_distinct(order.table$txn.date), min = 1, max = n_distinct(order.table$txn.date)))
    ), style = "color: #ffffff"),
    fluidRow(div(column(width = 4, h4("Prediction Parameter")), style = "color: #ffffff")),
    fluidRow(div(
      column(width = 3, numericInput(inputId = ns("predictPeriodLength"), label = "Length of Prediction", value = 5, min = 1, max = 10)),
      column(width = 3, radioButtons(inputId = ns("predictPrecision"), label = "Period of Length", choices = list("By year" = "year", "By quarter" = "quarter", "By month" = "month"), inline = TRUE)),
      column(width = 3, radioButtons(inputId = ns("discountRate"), label = "Discount Rate", choices = list("5%" = "0.05", "10%" = "0.1", "15%" = "0.15", "20%" = "0.2"), inline = TRUE))
    ), style = "color: #ffffff"),
    fluidRow(
      column(width = 3, actionButton(inputId=ns("run"), label = "RUN", icon = icon("paper-plane"), style="color: #ffffff; background-color: #1976d2")),
      column(width = 3, actionButton(inputId = ns("clear"), label = "CLEAR", icon = icon("trash-alt"), style="color: #ffffff; background-color: #1976d2"))
    ),
    fluidRow(
      column(width = 3, helpText("After click RUN, please wait for 60 seconds and results will appear."))
    ),
    fluidRow(column(width = 12, div(dataTableOutput(outputId = ns("dspTable"), height="300px"), style="color: #ffffff")))
  )
}


# module server
clvModelFitting <- function(input, output, session, order.table) {
  clv.output <- reactiveValues(model=NULL, params=NULL)
  clv.summary <- reactiveValues(table=NULL)
  clv.select <- reactiveValues()

  observeEvent(input$run, {
    date.range.gte <- as.Date(input$dateRange[1], origin="1970-01-01")
    date.range.lte <- as.Date(input$dateRange[2], origin="1970-01-01")
    avg.ticket.range.gte <- as.numeric(input$avgTicketRange[1])
    avg.ticket.range.lte <- as.numeric(input$avgTicketRange[2])
    max.repurchase <- as.numeric(input$maxRepurchase)

    clv.input <- formatInputCLV(
      order.table, date.range=list(gte=date.range.gte, lte=date.range.lte),
      avg.ticket.range=list(gte=avg.ticket.range.gte, lte=avg.ticket.range.lte),
      max.repurchase=max.repurchase
    )

    discount.rate <- as.numeric(input$discountRate)
    predict.precision <- input$predictPrecision
    predict.period.length <- input$predictPeriodLength

    model.output <- getOutputCLV(
      clv.input, discount.rate=discount.rate, predict.precision=predict.precision,
      predict.period.length=predict.period.length
    )

    clv.output$model <- model.output$model
    clv.output$params <- model.output$params
    rm(model.output)
    clv.output$model$recency.rate <- clv.output$model$t.x / (clv.output$model$x + 1)
    clv.select$select.order.table <- order.table[(customer.id %in% clv.output$model$customer.id) & (txn.date >= date.range.gte) & (txn.date <= date.range.lte)]
  })

  # Clear clv ouput followed by disapprearance of all graphs
  observeEvent(input$clear, {
    clv.output$model <- NULL
    clv.output$params <- NULL
    clv.summary$table <- NULL
  })

  # Get a descriptive table of rfm, #expected.number.transaction, and clv
  observeEvent(clv.output$model, {
    clv.summary$table <- descriptive.data(table = clv.output$model,
      number.col = c("t.x", "x", "avg.ticket", "expected.number.transactions", "clv"))
    })

  # 描述性统计:Recency, Frequency, ATV, Expected Txn, CLV
  output$dspTable <- renderDataTable({
    if (is.null(clv.summary$table)) return()

    rownames(clv.summary$table) <- c("Difference Between First and Last Transaction Date", "Repurchase Times", "Average Transaction Value", "Predicted Purchase Times", "Customer Lifetime Value")
    datatable(
      clv.summary$table,
      options = list(searching=FALSE, paging=FALSE, ordering=FALSE,info=FALSE)
    ) %>%
      formatStyle(c(0:length(colnames(clv.summary$table))), color="#000000")
  })

  return(list(
    clv.output.model = reactive(clv.output$model),
    select.order.table = reactive(clv.select$select.order.table)
  ))
}
