--ユベル－Ｄａｓ Ｅｗｉｇ Ｌｉｅｂｅ Ｗäｃｈｔｅｒ
--Yubel - Das Ewig Liebe Wächter
--Scripted by Eerie Code, modified as requested
-- Lua
local s,id=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    --Fusion Summon procedure (Any monster can be used as Fusion Material)
    Fusion.AddProcMixRep(c,true,true,aux.FilterBoolFunctionEx(Card.IsType,TYPE_MONSTER),2,99)
    --Inflict 500 damage to your opponent for each Fusion Material
    local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
    e1:SetCategory(CATEGORY_DAMAGE)
    e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EVENT_SPSUMMON_SUCCESS)
    e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) end)
    e1:SetTarget(s.damtg)
    e1:SetOperation(s.damop)
    c:RegisterEffect(e1)
    --Cannot be destroyed by battle or card effects
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetValue(1)
    c:RegisterEffect(e2)
    local e3=e2:Clone()
    e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    c:RegisterEffect(e3)
    --Unaffected by opponent's card effects
    local e4=Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_SINGLE)
    e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e4:SetCode(EFFECT_IMMUNE_EFFECT)
    e4:SetRange(LOCATION_MZONE)
    e4:SetValue(s.efilter)
    c:RegisterEffect(e4)
    --You take no battle damage from battles involving this card
    local e5=e2:Clone()
    e5:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    c:RegisterEffect(e5)
    --Inflict damage to your opponent equal to their monster's ATK and banish that monster
    local e6=Effect.CreateEffect(c)
    e6:SetDescription(aux.Stringid(id,1))
    e6:SetCategory(CATEGORY_DAMAGE+CATEGORY_REMOVE)
    e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
    e6:SetCode(EVENT_DAMAGE_STEP_END)
    e6:SetCondition(s.damrmcon)
    e6:SetTarget(s.damrmtg)
    e6:SetOperation(s.damrmop)
    c:RegisterEffect(e6)
end

-- Efeito para fazer com que não seja afetada por efeitos do oponente
function s.efilter(e,re)
    return re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end

-- Função para calcular e infligir dano com base nos materiais de fusão
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
    local mg=e:GetHandler():GetMaterial()
    if chk==0 then return mg and #mg>0 end
    local dmg=#mg*500
    Duel.SetTargetPlayer(1-tp)
    Duel.SetTargetParam(dmg)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dmg)
end

function s.damop(e,tp,eg,ep,ev,re,r,rp)
    local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
    Duel.Damage(p,d,REASON_EFFECT)
end

-- Condição para infligir dano e remover o monstro do oponente
function s.damrmcon(e,tp,eg,ep,ev,re,r,rp)
    local bc=e:GetHandler():GetBattleTarget()
    if not bc then return false end
    if bc:IsRelateToBattle() then
        return bc:IsControler(1-tp)
    else
        return bc:IsPreviousControler(1-tp)
    end
end

function s.damrmtg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return true end
    local bc=e:GetHandler():GetBattleTarget()
    local dam=0
    if bc:IsRelateToBattle() then
        dam=bc:GetAttack()
        Duel.SetOperationInfo(0,CATEGORY_REMOVE,bc,1,0,0)
    else
        dam=bc:GetPreviousAttackOnField()
        e:SetLabel(dam)
    end
    e:SetLabelObject(bc)
    Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end

function s.damrmop(e,tp,eg,ep,ev,re,r,rp)
    local dam=0
    local bc=e:GetLabelObject()
    local battle_relation=bc:IsRelateToBattle()
    if battle_relation and bc:IsFaceup() and bc:IsControler(1-tp) then
        dam=bc:GetAttack()
    elseif not battle_relation then
        dam=e:GetLabel()
    end
    if Duel.Damage(1-tp,dam,REASON_EFFECT)>0 and battle_relation then
        Duel.Remove(bc,POS_FACEUP,REASON_EFFECT)
    end
end
