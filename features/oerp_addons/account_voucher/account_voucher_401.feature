###############################################################################
#
#    OERPScenario, OpenERP Functional Tests
#    Copyright 2009 Camptocamp SA
#
##############################################################################
##############################################################################
# Branch      # Module       # Processes     # System
@addons       @account_voucher       @4     @401

Feature: In order to validate multicurrency account_voucher behaviour as an admin user I do a reconciliation run.
         I want to create a customer invoice for 1000 EUR (rate : 1) and pay it in full in EUR (rate : 1)
         with account_voucher. 

  @account_voucher_run
  Scenario: Create invoice 401
  Given I need a "account.invoice" with oid: scen.voucher_inv_401
    And having:
      | name               | value                              |
      | name               | SI_401                             |
      | date_invoice       | %Y-01-01                           |
      | date_due           | %Y-02-15                           |
      | address_invoice_id | by oid: scen.partner_1_add         |
      | partner_id         | by oid: scen.partner_1             |
      | account_id         | by name: Debtors                   |
      | journal_id         | by name: Sales                     |
      | currency_id        | by name: EUR                       |
      | type               | out_invoice                        |

    Given I need a "account.invoice.line" with oid: scen.voucher_inv401_line401
    And having:
      | name       | value                           |
      | name       | invoice line 401                |
      | quantity   | 1                               |
      | price_unit | 1000                            |
      | account_id | by name: Sales                  |
      | invoice_id | by oid: scen.voucher_inv_401    |
    Given I find a "account.invoice" with oid: scen.voucher_inv_401
    And I open the credit invoice

  @account_voucher_run
  Scenario: Create Statement 401
    Given I need a "account.bank.statement" with oid: scen.voucher_statement_401
    And having:
     | name        | value                             |
     | name        | Bk.St.401                         |
     | date        | %Y-02-15                          |
     | currency_id | by name: EUR                      |
     | journal_id  | by oid: scen.voucher_eur_journal  |
    And the bank statement is linked to period "02/%Y"

 @account_voucher_run @account_voucher_import_invoice
  Scenario: Import invoice into statement
    Given I find a "account.bank.statement" with oid: scen.voucher_statement_401
    And I import invoice "SI_401" using import invoice button

  @account_voucher_run @account_voucher_confirm
  Scenario: confirm bank statement (/!\ Voucher payment options must be 'reconcile payment balance' by default )
    Given I find a "account.bank.statement" with oid: scen.voucher_statement_401
    And I set bank statement end-balance
    When I confirm bank statement

  @account_voucher_run @account_voucher_valid_401
  Scenario: validate voucher
    Given I find a "account.bank.statement" with oid: scen.voucher_statement_401
    Then I should have following journal entries in voucher:
      | date     | period   | account                           |  debit | credit | curr.amt | curr. | reconcile | partial |
      | %Y-02-15 | 02/%Y    | Debtors                           |        |1000.00 |          |       | yes       |         |
      | %Y-02-15 | 02/%Y    | EUR bank account                  |1000.00 |        |          |       |           |         |

  @account_voucher_run @account_voucher_valid_invoice_401
  Scenario: validate voucher
    Given My invoice "SI_401" is in state "paid" reconciled with a residual amount of "0.0"
