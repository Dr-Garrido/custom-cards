-- Nephthys Shrine of Reincarnation
local s,id=GetID()
function s.initial_effect(c)
    -- Activate WIND "Nephthys" Ritual Monsters' effects as Quick Effects in GY
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)

    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_QP_ACT_IN_NTPHAND)
    e1:SetRange(LOCATION_SZONE)
    e1:SetTargetRange(LOCATION_GRAVE,0)
    e1:SetTarget(s.qetg)
    c:RegisterEffect(e1)

    -- If you control a monster in the Extra Monster Zone that is not a "Nephthys" monster, banish this card and all monsters you control
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCode(EVENT_ADJUST)
    e2:SetCondition(s.rmcon)
    e2:SetOperation(s.rmop)
    c:RegisterEffect(e2)

    -- Destroy 1 card in your hand, OR if destroyed by card effect, add 1 "Nephthys" Spell/Trap
    local e3=Effect.CreateEffect(c)
    e3:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
    e3:SetType(EFFECT_TYPE_IGNITION)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCountLimit(1,id)
    e3:SetTarget(s.destg)
    e3:SetOperation(s.desop)
    c:RegisterEffect(e3)

    -- If destroyed by card effect, add 1 "Nephthys" Spell/Trap from Deck to hand
    local e4=Effect.CreateEffect(c)
    e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
    e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_DESTROYED)
    e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
    e4:SetCondition(s.thcon)
    e4:SetCost(s.thcost)
    e4:SetTarget(s.thtg)
    e4:SetOperation(s.thop)
    c:RegisterEffect(e4)

    -- Special Summon 1 "Nephthys" monster if a card in hand or field is destroyed
    local e5=Effect.CreateEffect(c)
    e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
    e5:SetCode(EVENT_DESTROYED)
    e5:SetProperty(EFFECT_FLAG_DELAY)
    e5:SetRange(LOCATION_SZONE)
    e5:SetCountLimit(1,id+100)
    e5:SetCondition(s.spcon)
    e5:SetTarget(s.sptg)
    e5:SetOperation(s.spop)
    c:RegisterEffect(e5)
end

-- e1: Activate WIND "Nephthys" Ritual Monsters' effects as Quick Effects from the GY
function s.qetg(e,c)
    return c:IsSetCard(0x11f) and c:IsType(TYPE_RITUAL) and c:IsAttribute(ATTRIBUTE_WIND)
end

-- e2: If you control a monster in the Extra Monster Zone that is not a "Nephthys" monster, banish this card and all monsters you control
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
    -- Verifica se existe um monstro na Extra Monster Zone que não é um "Nephthys"
    return Duel.IsExistingMatchingCard(function(c) 
        return c:IsFaceup() and not c:IsSetCard(0x11f) and c:IsLocation(LOCATION_EXTRA) 
    end, tp, LOCATION_EXTRA, 0, 1, nil)
end

function s.rmop(e,tp,eg,ep,ev,re,r,rp)
    -- Banish this card and all monsters in the Extra Monster Zone
    Duel.Banish(e:GetHandler(), REASON_EFFECT)
    local g = Duel.GetFieldGroup(tp, LOCATION_EXTRA, 0) -- Obtém monstros da Zona Extra
    if #g > 0 then
        Duel.Banish(g, REASON_EFFECT)
    end
end

-- e3: Destroy 1 card in hand OR add 1 "Nephthys" Spell/Trap if destroyed by a card effect
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_HAND,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    if e:GetHandler():IsRelateToEffect(e) then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
        local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_HAND,0,1,1,nil)
        if #g>0 then
            Duel.Destroy(g,REASON_EFFECT)
        end
    end
end

-- e4: Add 1 "Nephthys" Spell/Trap from Deck to hand if destroyed by card effect
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return r&REASON_EFFECT~=0
end

function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.CheckLPCost(tp,1000) end
    Duel.PayLPCost(tp,1000)
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thfilter(c)
    return c:IsSetCard(0x11f) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
    local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
    if #g>0 then
        Duel.SendtoHand(g,nil,REASON_EFFECT)
        Duel.ConfirmCards(1-tp,g)
    end
end

-- e5: Special Summon 1 "Nephthys" monster if a card in hand or field is destroyed
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.spfilter,1,nil,tp) and (not re or re:GetHandler()~=e:GetHandler())
end

function s.spfilter(c,tp)
    return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_HAND+LOCATION_ONFIELD)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end

function s.spfilter2(c,e,tp)
    return c:IsSetCard(0x11f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
    if #g>0 then
        Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
    end
end
