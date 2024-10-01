-- Script para um card de monstro

function Card.initial_effect(c)
    -- Efeito 1: Não é afetado por efeitos de outros cards
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_IMMUNE_EFFECT)
    e1:SetValue(Card.immune_effect)
    c:RegisterEffect(e1)

    -- Efeito 2: Não pode ser destruído em batalha
    local e2=Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e2:SetValue(1)
    c:RegisterEffect(e2)

    -- Efeito 3: Pode atacar diretamente
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_SINGLE)
    e3:SetCode(EFFECT_DIRECT_ATTACK)
    c:RegisterEffect(e3)
end

-- Função que determina a imunidade a efeitos de outros cards
function Card.immune_effect(e,te)
    return te:GetOwner()~=e:GetOwner()
end
