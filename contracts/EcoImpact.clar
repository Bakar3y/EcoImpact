;; EcoImpact Protocol
;; A decentralized environmental sustainability incentive system with NFT impact certificates

;; Constants
(define-constant MAX_CARBON_CREDITS u1000000)
(define-constant BASE_ACTION_REWARD u10)
(define-constant CONSISTENCY_BONUS u2)
(define-constant MAX_CONSISTENCY_TIER u7)
(define-constant ERR_INVALID_ACTION u1)
(define-constant ERR_NO_CREDITS u2)
(define-constant ERR_RESERVE_EMPTY u3)
(define-constant BLOCKS_PER_DAY u144)
(define-constant PLEDGE_BONUS u2)
(define-constant MIN_PLEDGE_PERIOD u288)
(define-constant EARLY_WITHDRAWAL_PENALTY u10)

;; Data Variables
(define-data-var total-credits-issued uint u0)
(define-data-var total-actions-completed uint u0)
(define-data-var platform-administrator principal tx-sender)
(define-data-var last-certificate-id uint u0)

;; Data Maps
(define-map user-actions principal uint)
(define-map user-credits principal uint)
(define-map action-registration-block principal uint)
(define-map impact-streak principal uint)
(define-map last-action-block principal uint)
(define-map pledged-credits principal uint)
(define-map pledge-start-block principal uint)

;; NFT Data Maps
(define-map certificate-ownership {id: uint} {owner: principal})
(define-map certificate-metadata {id: uint} {action-impact: uint, completion-block: uint, streak-level: uint})
(define-map user-certificates principal (list 100 uint))

;; Public Functions

(define-public (register-eco-action (impact uint))
  (begin
    (asserts! (> impact u0) (err ERR_INVALID_ACTION))
    (map-set action-registration-block tx-sender burn-block-height)
    (ok true)
  )
)

(define-public (complete-eco-action (impact uint))
  (let ((registration-block (default-to u0 (map-get? action-registration-block tx-sender))))
    (asserts! (> registration-block u0) (err ERR_INVALID_ACTION))
    (asserts! (>= (- burn-block-height registration-block) impact) (err ERR_INVALID_ACTION))
    
    (let ((previous-action-block (default-to u0 (map-get? last-action-block tx-sender)))
          (streak (default-to u0 (map-get? impact-streak tx-sender)))
          (new-streak (if (< (- burn-block-height previous-action-block) BLOCKS_PER_DAY)
                        (+ streak u1)
                        u1))
          (capped-streak (if (<= streak MAX_CONSISTENCY_TIER) streak MAX_CONSISTENCY_TIER))
          (credit-amount (+ BASE_ACTION_REWARD (* capped-streak CONSISTENCY_BONUS)))
          (certificate-id (+ (var-get last-certificate-id) u1)))
      
      ;; Update user records
      (map-set user-actions tx-sender (+ (default-to u0 (map-get? user-actions tx-sender)) u1))
      (map-set user-credits tx-sender (+ (default-to u0 (map-get? user-credits tx-sender)) credit-amount))
      (map-set impact-streak tx-sender new-streak)
      (map-set last-action-block tx-sender burn-block-height)
      
      ;; Update platform stats
      (var-set total-actions-completed (+ (var-get total-actions-completed) u1))
      (var-set total-credits-issued (+ (var-get total-credits-issued) credit-amount))
      (asserts! (<= (var-get total-credits-issued) MAX_CARBON_CREDITS) (err ERR_RESERVE_EMPTY))
      
      ;; Mint NFT impact certificate
      (var-set last-certificate-id certificate-id)
      (map-set certificate-ownership {id: certificate-id} {owner: tx-sender})
      (map-set certificate-metadata {id: certificate-id} {action-impact: impact, completion-block: burn-block-height, streak-level: capped-streak})
      
      ;; Add certificate to user's collection
      (let ((user-certificate-list (default-to (list) (map-get? user-certificates tx-sender))))
        (map-set user-certificates tx-sender (unwrap-panic (as-max-len? (append user-certificate-list certificate-id) u100)))
        (ok credit-amount)
      )
    )
  )
)

(define-public (claim-carbon-credits)
  (let ((credit-balance (default-to u0 (map-get? user-credits tx-sender))))
    (asserts! (> credit-balance u0) (err ERR_NO_CREDITS))
    (map-set user-credits tx-sender u0)
    (ok credit-balance)
  )
)

;; Pledge Features

(define-public (pledge-credits (amount uint))
  (begin
    (asserts! (> amount u0) (err ERR_INVALID_ACTION))
    (asserts! (>= (var-get total-credits-issued) amount) (err ERR_RESERVE_EMPTY))
    (map-set pledged-credits tx-sender amount)
    (map-set pledge-start-block tx-sender burn-block-height)
    (var-set total-credits-issued (- (var-get total-credits-issued) amount))
    (ok amount)
  )
)

(define-public (withdraw-pledge)
  (let ((pledged-amount (default-to u0 (map-get? pledged-credits tx-sender)))
        (pledge-block (default-to u0 (map-get? pledge-start-block tx-sender))))
    
    (asserts! (> pledged-amount u0) (err ERR_NO_CREDITS))
    
    (let ((blocks-pledged (- burn-block-height pledge-block))
          (penalty (if (< blocks-pledged MIN_PLEDGE_PERIOD) 
                     (/ (* pledged-amount EARLY_WITHDRAWAL_PENALTY) u100) 
                     u0))
          (final-amount (- pledged-amount penalty)))
      
      (map-set pledged-credits tx-sender u0)
      (map-set pledge-start-block tx-sender u0)
      (var-set total-credits-issued (+ (var-get total-credits-issued) final-amount))
      (ok final-amount)
    )
  )
)

;; Read-Only Functions

(define-read-only (get-completed-actions (user principal))
  (default-to u0 (map-get? user-actions user))
)

(define-read-only (get-credit-balance (user principal))
  (default-to u0 (map-get? user-credits user))
)

(define-read-only (get-impact-streak (user principal))
  (default-to u0 (map-get? impact-streak user))
)

(define-read-only (get-platform-stats)
  {
    total-actions-completed: (var-get total-actions-completed),
    total-credits-issued: (var-get total-credits-issued),
    total-certificates-issued: (var-get last-certificate-id)
  }
)

;; NFT Read-Only Functions

(define-read-only (get-certificate-owner (certificate-id uint))
  (let ((certificate-data (map-get? certificate-ownership {id: certificate-id})))
    (if (is-some certificate-data)
        (some (get owner (unwrap-panic certificate-data)))
        none
    )
  )
)

(define-read-only (get-certificate-metadata (certificate-id uint))
  (map-get? certificate-metadata {id: certificate-id})
)

(define-read-only (get-user-certificates (user principal))
  (default-to (list) (map-get? user-certificates user))
)

(define-read-only (get-certificate-count)
  (var-get last-certificate-id)
)

;; Private Functions

(define-private (is-platform-administrator)
  (is-eq tx-sender (var-get platform-administrator))
)
