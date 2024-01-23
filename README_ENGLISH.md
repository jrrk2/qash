# Qash

A programming language for double-entry accounting, inspired by [Beancount](https://github.com/beancount/beancount).

## Example

````
!open-account asset Assets:Current assets:Hoge Bank savings account JPY #cash
!open-account asset Asset:Current assets:Cash JPY #cash
!open-account asset Asset: Advance payment JPY
!open-account equity capital: Starting balance JPY
!open-account expense Expense: Food JPY
!open-account income Income:Salary JPY
!open-account liability Liability: Accounts payable JPY

(* comment *)
* 2023-05-08 "Convenience store" #tag 1 #tag 2
   Assets: Current assets: Cash -502
   Cost: Food cost 502

!import "01_overlay.qash"
   * 2023-05-09 "Convenience Store Fuga"
     Assets: Current assets: Cash -1502
     Cost: Meal cost 1300
     Assets: Advance payment 202

// comment
````

## Usage

````
NAME
        qash - A command-line accounting tool

SYNOPSIS
        qash COMMAND...

COMMANDS
        check [OPTION]… FILE


        dump [OPTION]… IN-FILE OUT-FILE


        generate [OPTION]… NUM-ENTRIES


        of-gnucash-csv [OPTION]… TRANSACTIONS-CSV-FILE


        of-json [OPTION]… FILE


        serve [OPTION]… IN-FILE


        to-json [OPTION]… FILE
````

## Hands-on: Start household accounting with Qash

Here, we will write the information necessary to keep a household account book using Qash.
Qash is designed based on a bookkeeping method called double entry accounting.
In the following, I will not use the term "double-entry bookkeeping" and will intentionally mix Qash-specific matters with general double-entry bookkeeping matters.

It is assumed that you know how to use basic Linux commands and how to use an editor.
No knowledge of double entry bookkeeping is required.

Qash represents all transactions as movements of money between **accounts**.
Here, account is a label to distinguish money,
For example, it refers to "cash", "xxx bank savings account", "advance money", "starting balance", "yyy credit card", "food expenses", "salary", etc.
There are five account items: **asset**, **liability**, **equity**, **expense**, and **income**. It is divided into
In the above example, "cash", "xxx bank savings account", and "advance money" are assets, "starting balance" is capital, "yyy credit card" is a liability, "food expenses" is an expense,
“Salary” is revenue.
Equity (also known as net worth) may be unfamiliar to you, but
In this text, you can safely assume that capital is another name for opening balance.
Below, we will mainly deal with matters other than capital (assets, liabilities, expenses, and revenue).

Now, account items have balances associated with them. For example, if the balance of the account item "cash" is 10,000 yen,
It (simply) indicates that the current cash amount is 10,000 yen. Similarly, if the balance of the account item "xxx bank savings account" is 1,000,000 yen,
xxx You should have 1,000,000 yen in your bank savings account. The same goes for debts, and the balance of the account "yyy credit card" is
10,000 yen means that the total amount to be debited from your credit card from the next time onwards will be 10,000 yen.
There are balances for expenses and income, but for these accounts, the total for each period is more important.
In other words, rather than the total food expenses for the entire period of keeping a household account book (this is the balance),
Food expenses in August 2023 make more sense. In Qash, this is displayed in the "chart" described below.

As mentioned earlier, it is expressed as the movement of money between all the trading accounts recorded in Qash.
All transactions are subject to the following principles:

- Describe increases in assets and expenses as positive (`+`) values. Conversely, a decrease in assets/expenses is written as a negative (`-`) value.
- Increases in debt, equity, and revenue are written as negative (`-`) values. Conversely, increases in debt, equity, and revenue are written as positive (`+`) values.
- The sum of all values included in one transaction is always `0`.

Qash will print an error if it finds a transaction that does not meet these principles (especially the last one).

Here is an example (in Japanese) of a transaction that can be made with Qash. Try to meet the above principles and make sure your final balance is what you expected.

- Example 1: If you pay 1000 yen for meals in cash, the account item "Cash" is `-1000` and the account item "Meal expenses" is `+1000`.
- Example 2: If you pay 1000 yen for food with yyy credit card, the account "yyy credit card" will be `-1000` and the account "food expense" will be `+1000`.
- Example 3: If salary 200,000 yen is transferred to xxx bank savings account, the account "Salary" is `-200,000` and the account "xxx bank savings account" is `+200,000`
- Example 4: If you pay a total of 6,000 yen, including a friend's portion (3,000 yen), in cash at a restaurant, and later receive the advance payment in your xxx bank savings account, record the following two transactions:
   - Transaction 1: Account "cash" is `-6000`, account "food expense" is `+3000`, account "advance" is `+3000`
   - Transaction 2: Account item “Advance money” is `-3000`, account item “xxx bank savings deposit” is `+3000`
- Example 5: If you transfer 200,000 yen from xxx bank savings account to zzz bank savings account, the account item ``xxx bank savings account'' will be `-200,000`, and the account item ``zzz bank savings account'' will be `+200,000`

Now let's actually write a transaction using Qash.
Qash is a simple programming language for describing transactions like the one above.
You can manage your household finances using your favorite text editor or a version control tool like Git.

First, get Qash. Qash is written in OCaml, so
First you need to install OCaml.

```console
# Introduce OPAM, OCaml's package manager, and install OCaml
$ bash -c "sh <(curl -fsSL https://raw.githubusercontent.com/ocaml/opam/master/shell/install.sh)"
$ opam init # Initialize OPAM and install OCaml
$ eval $(opam env --switch=default)

# Download Qash source code and build
$ git clone https://github.com/ushitora-anqou/qash.git
$ cd qash
$ opam install . --deps-only
$ dune build bin/main.exe
$ _build/default/bin/main.exe --version
0.1.0
````

Next, start your favorite text editor and enter the following,
Save it with a file name of your choice (`root.qash` here).

````
// ← Lines starting with this are comments.
(* ← Start a multi-line comment with this,
    This is the end → *)
(* You can also nest (* you can (* ma *) *) *)

(*
   First, define the accounts. Use the !open-account command.
   Add #cash to items that are treated as cash in cash flow calculations.
*)
!open-account asset cash JPY #cash
!open-account asset xxx Bank savings account JPY #cash
!open-account asset zzz bank savings account JPY #cash
!open-account asset advance payment JPY
!open-account equity starting balance JPY
!open-account liability yyyCredit card JPY
!open-account expense Food expenses JPY
!open-account income Salary JPY

(*
   Next, write the transaction. The syntax is as follows.

   * YYYY-MM-DD "Description" #tag
      Account Amount
      ...

   however:
   - #tag is optional. It is not used in the example below.
   - The amount can be omitted only in one place. If omitted,
     Automatically completes the total to 0.
*)

// First, set the starting balance. Any date is fine.
* 2023-01-01 "Starting Balance"
   Cash 30,000 // With or without commas doesn't matter
   xxxBank savings deposit 1,000,000
   Starting balance

// Example 1: If you pay 1000 yen for food in cash,
//Account "cash" is `-1000`, account "food expense" is `+1000`
* 2023-01-02 "Example 1"
   Cash -1,000
   Food cost 1,000

// Example 2: If you pay 1000 yen for food with yyy credit card,
// The account "yyy credit card" is `-1000`, the account "food expense" is `+1000`
* 2023-01-03 "Example 2"
   yyycredit card -1,000
   Food cost 1,000

// Example 3: If the salary of 200,000 yen is transferred to xxx bank savings account,
// Account "Salary" is `-200,000`, account "xxx Bank Savings Deposit" is `+200,000`
* 2023-01-04 "Example 3"
   Salary -200,000
   xxx Bank savings deposit 200,000

// Example 4: Eating and drinking
