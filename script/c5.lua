-- Nephthys Ritual Revival
local s,id=GetID()
function s.initial_effect(c)
    -- Activate
    local e0=Effect.CreateEffect(c)
    e0:SetType(EFFECT_TYPE_ACTIVATE)
    e0:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e0)
    
    -- Ritual Summon "Nephthys" Ritual Monster from GY
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end

-- Check for "Nephthys" monsters in hand or field, and "Nephthys" Link Monsters in GY
function s.filter(c,e,tp,m1,m2,ft)
    if not c:IsSetCard(0x11f) or not c:IsRitualMonster() or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
    local mg=m1:Clone()
    if ft>0 then
        mg:Merge(m2)
    else
        mg:RemoveCard(c)
    end
    return mg:CheckWithSumGreater(Card.GetRitualLevel,c:GetLevel(),c)
end

-- Ritual Summon target
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local mg1=Duel.GetRitualMaterial(tp)
        local mg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_GRAVE,0,nil)
        return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,mg1,mg2,Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end

-- Filter for Nephthys Link Monsters in the GY
function s.filter2(c)
    return c:IsSetCard(0x11f) and c:IsType(TYPE_LINK) and c:IsAbleToRemove()
end

-- Ritual Summon operation
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    local mg1=Duel.GetRitualMaterial(tp)
    local mg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_GRAVE,0,nil)
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
    local tg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,mg1,mg2,Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
    if #tg>0 then
        local tc=tg:GetFirst()
        local mg=mg1:Clone()
        if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
            mg:Merge(mg2)
        end
        local mat=nil
        if mg:CheckWithSumGreater(Card.GetRitualLevel,tc:GetLevel(),tc) then
            Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
            mat=mg:SelectWithSumGreater(tp,Card.GetRitualLevel,tc:GetLevel(),tc)
        end
        if mat then
            tc:SetMaterial(mat)
            Duel.ReleaseRitualMaterial(mat)
            Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
            tc:CompleteProcedure()
            -- Check if "Connector of Nephthys" or "Sacred Phoenix of Nephthys" was destroyed
            if mat:IsExists(s.drawfilter,1,nil) then
                Duel.BreakEffect()
                Duel.Draw(tp,1,REASON_EFFECT)
            end
        end
    end
end

-- Check if "Connector of Nephthys" or "Sacred Phoenix of Nephthys" was destroyed
function s.drawfilter(c)
    return c:IsCode(14139645) or c:IsCode(75285069) -- Connector of Nephthys and Sacred Phoenix of Nephthys
end
