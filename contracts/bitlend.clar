;; Title: BitLend - Bitcoin-Collateralized Lending Protocol
;;
;; Summary:
;; A decentralized lending protocol enabling Bitcoin holders to unlock liquidity while retaining BTC exposure.
;; Built on Stacks, BitLend offers enterprise-grade security, capital efficiency, and Bitcoin compliance.
;;
;; Description:
;; BitLend is a non-custodial lending platform where users can collateralize Bitcoin to borrow stablecoins.
;; The protocol features dynamic risk parameters, real-time price feeds, and automated liquidation mechanisms
;; to ensure system solvency. By leveraging Stacks' Bitcoin-anchored security, BitLend provides a trust-minimized
;; solution for Bitcoin-backed loans.

;; CORE CONSTANTS

(define-constant CONTRACT-OWNER tx-sender)

;; Error Definitions
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INSUFFICIENT-COLLATERAL (err u101))
(define-constant ERR-BELOW-MINIMUM (err u102))
(define-constant ERR-INVALID-AMOUNT (err u103))
(define-constant ERR-ALREADY-INITIALIZED (err u104))
(define-constant ERR-NOT-INITIALIZED (err u105))
(define-constant ERR-INVALID-LIQUIDATION (err u106))
(define-constant ERR-LOAN-NOT-FOUND (err u107))
(define-constant ERR-LOAN-NOT-ACTIVE (err u108))
(define-constant ERR-INVALID-LOAN-ID (err u109))
(define-constant ERR-INVALID-PRICE (err u110))
(define-constant ERR-INVALID-ASSET (err u111))

;; Supported Assets
(define-constant VALID-ASSETS (list "BTC" "STX"))

;; STATE VARIABLES

(define-data-var platform-initialized bool false)
(define-data-var minimum-collateral-ratio uint u150) ;; 150% minimum collateral ratio
(define-data-var liquidation-threshold uint u120) ;; 120% liquidation trigger
(define-data-var platform-fee-rate uint u1) ;; 1% platform fee
(define-data-var total-btc-locked uint u0) ;; Total BTC collateral locked
(define-data-var total-loans-issued uint u0) ;; Total loans created

;; DATA MAPS

;; Loan Registry
(define-map loans
  { loan-id: uint }
  {
    borrower: principal,
    collateral-amount: uint,
    loan-amount: uint,
    interest-rate: uint,
    start-height: uint,
    last-interest-calc: uint,
    status: (string-ascii 20),
  }
)

;; User Loan Tracking
(define-map user-loans
  { user: principal }
  { active-loans: (list 10 uint) }
)

;; Price Oracle Data
(define-map collateral-prices
  { asset: (string-ascii 3) }
  { price: uint }
)

;; PRIVATE FUNCTIONS

;; Calculate collateral-to-loan ratio
(define-private (calculate-collateral-ratio
    (collateral uint)
    (loan uint)
    (btc-price uint)
  )
  (let (
      (collateral-value (* collateral btc-price))
      (ratio (* (/ collateral-value loan) u100))
    )
    ratio
  )
)

;; Calculate accrued interest based on blocks
(define-private (calculate-interest
    (principal uint)
    (rate uint)
    (blocks uint)
  )
  (let (
      (interest-per-block (/ (* principal rate) (* u100 u144))) ;; Daily rate / blocks per day
      (total-interest (* interest-per-block blocks))
    )
    total-interest
  )
)

;; Check if position requires liquidation
(define-private (check-liquidation (loan-id uint))
  (let (
      (loan (unwrap! (map-get? loans { loan-id: loan-id }) ERR-LOAN-NOT-FOUND))
      (btc-price (unwrap! (get price (map-get? collateral-prices { asset: "BTC" }))
        ERR-NOT-INITIALIZED
      ))
      (current-ratio (calculate-collateral-ratio (get collateral-amount loan)
        (get loan-amount loan) btc-price
      ))
    )
    (if (<= current-ratio (var-get liquidation-threshold))
      (liquidate-position loan-id)
      (ok true)
    )
  )
)

;; Execute position liquidation
(define-private (liquidate-position (loan-id uint))
  (let (
      (loan (unwrap! (map-get? loans { loan-id: loan-id }) ERR-LOAN-NOT-FOUND))
      (borrower (get borrower loan))
    )
    (begin
      (map-set loans { loan-id: loan-id } (merge loan { status: "liquidated" }))
      (map-delete user-loans { user: borrower })
      (ok true)
    )
  )
)

;; Validate loan ID bounds
(define-private (validate-loan-id (loan-id uint))
  (and
    (> loan-id u0)
    (<= loan-id (var-get total-loans-issued))
  )
)

;; Validate supported asset
(define-private (is-valid-asset (asset (string-ascii 3)))
  (is-some (index-of VALID-ASSETS asset))
)

;; Validate price feed data
(define-private (is-valid-price (price uint))
  (and
    (> price u0)
    (<= price u1000000000000) ;; Reasonable price ceiling
  )
)

;; Filter helper for loan list updates
(define-private (not-equal-loan-id (id uint))
  (not (is-eq id id))
)

;; PUBLIC FUNCTIONS

;; Initialize BitVault Protocol
(define-public (initialize-platform)
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (not (var-get platform-initialized)) ERR-ALREADY-INITIALIZED)
    (var-set platform-initialized true)
    (ok true)
  )
)