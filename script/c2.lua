-- Controller of Nephthys
local s,id=GetID()
function s.initial_effect(c)
    -- Quick Effect: Destroy 1 card in hand, apply effect if "Nephthys" non-Ritual Monster, Special Summon this card
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND)
    e1:SetCountLimit(1,id)
    e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
    e1:SetTarget(s.destg)
    e1:SetOperation(s.desop)
    c:RegisterEffect(e1)

    -- During the next Standby Phase after this card was destroyed and sent to the GY, switch control of 1 monster
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_CONTROL)
    e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
    e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id+100)
    e2:SetCondition(s.ctcon)
    e2:SetTarget(s.cttg)
    e2:SetOperation(s.ctop)
    c:RegisterEffect(e2)
    -- Track if the card was destroyed by card effect
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_DESTROYED)
    e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e3:SetOperation(s.regop)
    c:RegisterEffect(e3)
end

-- Quick Effect: Destroy 1 card in your hand
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_HAND,0,1,nil)
        and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND)
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_HAND,0,1,1,nil)
    if #g>0 and Duel.Destroy(g,REASON_EFFECT)~=0 then
        local tc=g:GetFirst()
        if tc:IsSetCard(0x11f) and not tc:IsType(TYPE_RITUAL) then
            -- Apply the destroyed "Nephthys" monster's effect if it has one
            local te=tc:GetCardEffect(EFFECT_DESTROY_REPLACE)
            if te then
                te:UseCountLimit(tp)
                te:GetOperation()(e,tp,eg,ep,ev,re,r,rp)
            end
        end
        -- Special Summon "Controller of Nephthys" from the hand
        local c=e:GetHandler()
        if c:IsRelateToEffect(e) then
            Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
        end
    end
end

-- Register if the card was destroyed by card effect
function s.regop(e,tp,eg,ep,ev,re,r,rp)
    if r&REASON_EFFECT~=0 then
        e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,0,1)
    end
end

-- Condition for control switching effect (next Standby Phase after destruction by effect)
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():GetFlagEffect(id)~=0
end

-- Target monster to switch control
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToChangeControler,tp,0,LOCATION_MZONE,1,nil)
        and Duel.IsExistingMatchingCard(s.ctfilter,tp,LOCATION_GRAVE,0,1,nil) end
end

function s.ctfilter(c)
    return c:IsSetCard(0x11f) and c:IsLevel(8) and c:IsAbleToDeck()
end

-- Operation: Shuffle 1 Level 8 Nephthys monster into the Deck, switch control of 1 monster
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
    local g=Duel.SelectMatchingCard(tp,s.ctfilter,tp,LOCATION_GRAVE,0,1,1,nil)
    if #g>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
        local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToChangeControler,tp,0,LOCATION_MZONE,1,1,nil)
        if #sg>0 then
            Duel.HintSelection(sg)
            Duel.GetControl(sg,tp)
        end
    end
end
