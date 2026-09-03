--Vicious Theatre of the Femme Fatale
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon Procedure: 2+ Level 3 "Vicious Theatre" monsters
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x41e),3,3,nil,nil)
	--For each material this card has, monsters you control gain 300 ATK and monsters your opponent controls lose 300 ATK/DEF
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_UPDATE_ATTACK)
	e0:SetRange(LOCATION_MZONE)
	e0:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e0:SetValue(function(e,c) return (c:IsControler(e:GetHandlerPlayer()) and 300 or -300)*e:GetHandler():GetOverlayCount() end)
	c:RegisterEffect(e0)	
	local e1=e0:Clone()
	e1:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1)
	--If this card is Xyz Summoned, or if your opponent activates a card effect: You can detach 1 material from this card; roll a six-sided die and apply this effect based on the result
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DICE+CATEGORY_SET+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e) return e:GetHandler():IsXyzSummoned() end)
	e2:SetCost(Cost.DetachFromSelf(1))
	e2:SetTarget(s.efftg)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp==1-tp end)
	c:RegisterEffect(e3)	
end

s.listed_series={0x41e}
s.listed_names={id}
s.roll_dice=true

function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end

function s.setfilter(c)
	return c:IsSetCard(0x41e) and c:IsSpellTrap() and c:IsSSetable()
end

function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local dice=Duel.TossDice(tp,1)
	if dice>=1 and dice<=3 then
		--● 1, 2 or 3: Set 1 "Vicious Theatre" Spell/Trap from your Deck
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
		local sg=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #sg>0 then
			Duel.SSet(tp,sg)
		end
	elseif dice==4 or dice==5 then
		--● 4 or 5: Negate the effects of 1 face-up card on the field until the end of the next turn
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
		local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g)
			local tc=g:GetFirst()
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_PHASE|PHASE_END,2)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_PHASE|PHASE_END,2)
			tc:RegisterEffect(e2)
		end
	elseif dice==6 then
		--● 6: Inflict 1500 Damage to your opponent
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
		Duel.Damage(1-tp,1500,REASON_EFFECT)
	end
	--For the rest of this turn, this card cannot attack, also you cannot Special Summon from the Extra Deck, except DARK or LIGHT monsters
	local c=e:GetHandler()
	--Cannot attack
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(3206)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_ATTACK)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
	e3:SetReset(RESETS_STANDARD_PHASE_END)
	c:RegisterEffect(e3)	
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,4))
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e4:SetTargetRange(1,0)
	e4:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not (c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsAttribute(ATTRIBUTE_DARK)) end)
	e4:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e4,tp)
	--"Clock Lizard" check
	aux.addTempLizardCheck(c,tp,function(e,c) return not (c:IsAttribute(ATTRIBUTE_LIGHT) or c:IsAttribute(ATTRIBUTE_DARK)) end)
end
