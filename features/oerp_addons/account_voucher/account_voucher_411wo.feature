###############################################################################
#
#    OERPScenario, OpenERP Functional Tests
#    Copyright 2009 Camptocamp SA
#
##############################################################################
##############################################################################
# Branch      # Module       # Processes     # System
@addons       @account_voucher       @4     @411wo

Feature: In order to validate multicurrency account_voucher behaviour as an admin user I do a reconciliation run.
         I want to create a customer invoice for 1000 EUR (rate : 1) and pay 950 EUR (rate : 1). I consider the 50 EUR
         as write-off. 

  @account_voucher_run
  Scenario: Create invoice 411wo
  Given I need a "account.invoice" with oid: scen.voucher_inv_411wo
    And having:
      | name               | value                              |
      | name               | SI_411wo                           |
      | date_invoice       | %Y-01-01                           |
      | date_due           | %Y-02-15                           |
      | address_invoice_id | by oid: scen.partner_1_add         |
      | partner_id         | by oid: scen.partner_1             |
      | account_id         | by name: Debtors                   |
      | journal_id         | by name: Sales                     |
      | currency_id        | by name: EUR                       |
      | type               | out_invoice                        |


    Given I need a "account.invoice.line" with oid: scen.voucher_inv411wo_line411wo
    And having:
      | name       | value                           |
      | name       | invoice line 411wo              |
      | quantity   | 1                               |
      | price_unit | 1000                            |
      | account_id | by name: Sales                  |
      | invoice_id | by oid:scen.voucher_inv_411wo   |
    Given I find a "account.invoice" with oid: scen.voucher_inv_411wo
    And I open the credit invoice

  @account_voucher_run
  Scenario: Create Statement 411wo
    Given I need a "account.bank.statement" with oid: scen.voucher_statement_411wo
    And having:
     | name        | value                             |
     | name        | Bk.St.411wo                       |
     | date        | %Y-02-15                          |
     | currency_id | by name: EUR                      |
     | journal_id  | by oid:  scen.voucher_eur_journal |
    And the bank statement is linked to period "02/%Y"


 @account_voucher_run @account_voucher_import_invoice
  Scenario: Import invoice into statement
    Given I find a "account.bank.statement" with oid: scen.voucher_statement_411wo
    And I import invoice "SI_411wo" using import invoice button

 @acccout_voucher_run @account_statement_line_amount_modified   
  Scenario: Modify the paid amount of the imported invoice 
    Given I need a "account.bank.statement.line" with name: SI_411wo
    And the line amount should be 1000
    Then I modify the bank statement line amount to 950

 @acccout_voucher_run @account_voucher_with_wo
  Scenario: As this is a final payment, in the payment options, I want to post the write off into the wo account
    Then I set the payment options to choose the writeoff account code 658 

  @account_voucher_run @account_voucher_confirm
  Scenario: confirm bank statement 
    Given I find a "account.bank.statement" with oid: scen.voucher_statement_411wo
    And I set bank statement end-balance
    When I confirm bank statement

  @account_voucher_run @account_voucher_valid_411wo
  Scenario: validate voucher
    Given I find a "account.bank.statement" with oid: scen.voucher_statement_411wo
    Then I should have following journal entries in voucher:
      | date     | period  | account                        |  debit | credit | curr.amt | curr. | reconcile | partial |
      | %Y-02-15 | 02/%Y | Debtors                          |        |1000.00 |          |       |  yes      |         |
      | %Y-02-15 | 02/%Y | Write-off                        |  50.00 |        |          |       |           |         |
      | %Y-02-15 | 02/%Y | EUR bank account                 | 950.00 |        |          |       |           |         |


  @account_voucher_run @account_voucher_valid_invoice_411wo
  Scenario: validate voucher
    Given My invoice "SI_411wo" is in state "paid" reconciled with a residual amount of "0.0"
