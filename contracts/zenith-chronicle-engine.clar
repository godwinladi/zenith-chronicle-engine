;; Zenith Chronicle Engine
;; An immutable distributed ledger for chronicling personal quests, 
;; endeavors, and their realization status across blockchain infrastructure
;; Empowers individuals to inscribe, trace, and modify their progression toward excellence

;; ======================================================================
;; ERROR RESPONSE DEFINITIONS
;; ======================================================================
(define-constant ERR_ENTITY_MISSING (err u404))
(define-constant ERR_RECORD_EXISTS (err u409))
(define-constant ERR_INVALID_INPUT (err u400))

;; ======================================================================
;; STORAGE ARCHITECTURE DEFINITIONS
;; ======================================================================

;; Chronicle repository for participant endeavor specifications
(define-map quest-chronicles
    principal
    {
        endeavor-description: (string-ascii 100),
        realization-flag: bool
    }
)

;; Priority classification storage for participant endeavors
(define-map quest-priorities
    principal
    {
        priority-weight: uint
    }
)

;; Temporal constraint storage for endeavor completion
(define-map quest-schedules
    principal
    {
        target-block: uint,
        alert-state: bool
    }
)

;; ======================================================================
;; READ-ONLY VALIDATION OPERATIONS
;; ======================================================================

;; Validates presence of participant chronicle in distributed storage
;; Provides comprehensive metadata without state modification
(define-public (chronicle-validation-check)
    (let
        (
            (current-participant tx-sender)
            (chronicle-record (map-get? quest-chronicles current-participant))
        )
        (if (is-some chronicle-record)
            (let
                (
                    (record-data (unwrap! chronicle-record ERR_ENTITY_MISSING))
                    (description-length (len (get endeavor-description record-data)))
                    (completion-status (get realization-flag record-data))
                )
                (ok {
                    record-present: true,
                    description-size: description-length,
                    completion-achieved: completion-status
                })
            )
            (ok {
                record-present: false,
                description-size: u0,
                completion-achieved: false
            })
        )
    )
)

;; ======================================================================
;; COLLABORATIVE QUEST MANAGEMENT
;; ======================================================================

;; Assigns new endeavor chronicle to specified participant
;; Enables distributed accountability and group quest coordination
(define-public (assign-participant-quest
    (target-participant principal)
    (endeavor-text (string-ascii 100)))
    (let
        (
            (participant-record (map-get? quest-chronicles target-participant))
        )
        (if (is-none participant-record)
            (begin
                (if (is-eq endeavor-text "")
                    (err ERR_INVALID_INPUT)
                    (begin
                        (map-set quest-chronicles target-participant
                            {
                                endeavor-description: endeavor-text,
                                realization-flag: false
                            }
                        )
                        (ok "Quest chronicle successfully assigned to designated participant.")
                    )
                )
            )
            (err ERR_RECORD_EXISTS)
        )
    )
)

;; ======================================================================
;; PRIORITY AND SCHEDULING OPERATIONS
;; ======================================================================

;; Establishes importance classification for participant endeavor
;; Implements structured three-level priority system (1=minimal, 2=standard, 3=critical)
(define-public (set-quest-priority (priority-value uint))
    (let
        (
            (current-participant tx-sender)
            (participant-record (map-get? quest-chronicles current-participant))
        )
        (if (is-some participant-record)
            (if (and (>= priority-value u1) (<= priority-value u3))
                (begin
                    (map-set quest-priorities current-participant
                        {
                            priority-weight: priority-value
                        }
                    )
                    (ok "Quest priority classification successfully recorded in ledger.")
                )
                (err ERR_INVALID_INPUT)
            )
            (err ERR_ENTITY_MISSING)
        )
    )
)

;; Configures temporal boundaries for quest completion
;; Establishes blockchain-secured deadline for endeavor fulfillment
(define-public (configure-quest-timeline (completion-blocks uint))
    (let
        (
            (current-participant tx-sender)
            (participant-record (map-get? quest-chronicles current-participant))
            (completion-block-target (+ block-height completion-blocks))
        )
        (if (is-some participant-record)
            (if (> completion-blocks u0)
                (begin
                    (map-set quest-schedules current-participant
                        {
                            target-block: completion-block-target,
                            alert-state: false
                        }
                    )
                    (ok "Quest timeline parameters successfully configured.")
                )
                (err ERR_INVALID_INPUT)
            )
            (err ERR_ENTITY_MISSING)
        )
    )
)

;; ======================================================================
;; CORE CHRONICLE MANAGEMENT FUNCTIONS
;; ======================================================================

;; Inscribes initial endeavor chronicle into distributed ledger
;; Creates immutable record of personal commitment
(define-public (inscribe-new-chronicle 
    (endeavor-text (string-ascii 100)))
    (let
        (
            (current-participant tx-sender)
            (existing-chronicle (map-get? quest-chronicles current-participant))
        )
        (if (is-none existing-chronicle)
            (begin
                (if (is-eq endeavor-text "")
                    (err ERR_INVALID_INPUT)
                    (begin
                        (map-set quest-chronicles current-participant
                            {
                                endeavor-description: endeavor-text,
                                realization-flag: false
                            }
                        )
                        (ok "Personal endeavor chronicle successfully inscribed in ledger.")
                    )
                )
            )
            (err ERR_RECORD_EXISTS)
        )
    )
)

;; Modifies existing chronicle with updated specifications
;; Permits evolution of endeavors or completion marking
(define-public (modify-chronicle-entry
    (endeavor-text (string-ascii 100))
    (completion-state bool))
    (let
        (
            (current-participant tx-sender)
            (existing-chronicle (map-get? quest-chronicles current-participant))
        )
        (if (is-some existing-chronicle)
            (begin
                (if (is-eq endeavor-text "")
                    (err ERR_INVALID_INPUT)
                    (begin
                        (if (or (is-eq completion-state true) (is-eq completion-state false))
                            (begin
                                (map-set quest-chronicles current-participant
                                    {
                                        endeavor-description: endeavor-text,
                                        realization-flag: completion-state
                                    }
                                )
                                (ok "Personal endeavor chronicle successfully modified in ledger.")
                            )
                            (err ERR_INVALID_INPUT)
                        )
                    )
                )
            )
            (err ERR_ENTITY_MISSING)
        )
    )
)

;; Eliminates chronicle record from distributed storage permanently
;; Establishes clean foundation for new personal objectives
(define-public (erase-chronicle-record)
    (let
        (
            (current-participant tx-sender)
            (existing-chronicle (map-get? quest-chronicles current-participant))
        )
        (if (is-some existing-chronicle)
            (begin
                (map-delete quest-chronicles current-participant)
                (ok "Personal endeavor chronicle successfully erased from ledger.")
            )
            (err ERR_ENTITY_MISSING)
        )
    )
)

