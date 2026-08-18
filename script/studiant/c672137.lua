--Studiant Wakamo of Calamity
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_FAIRY),5,4,s.ovfilter,aux.Stringid(id,0),4,s.xyzop)
	--Cannot be used as material for a Fusion, Xyz, or Link Summon
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	e0:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_XYZ,SUMMON_TYPE_LINK))
	c:RegisterEffect(e0)
	--Gains these effects while in the Extra Monster Zone
	--● Destroy all other cards on the field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_EMZONE)
	e1:SetHintTiming(TIMING_SPSUMMON,TIMING_BATTLE_START|TIMING_BATTLE_END)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--● During the Draw Phase: You can attach the top card of your opponent's Deck to this card as material.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE|PHASE_DRAW)
	e2:SetRange(LOCATION_EMZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.atttg)
	e2:SetOperation(s.attop)
	c:RegisterEffect(e2)
	--● During the End Phase: You can banish 1 card from your GY; both players take 2700 damage.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,4))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_EMZONE)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.damcost)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)	

end

s.listed_series={0x45e}
s.listed_names={id}

function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsRank(3) and c:IsSetCard(0x45e,lc,SUMMON_TYPE_XYZ,tp)
		and c:IsType(TYPE_XYZ,lc,SUMMON_TYPE_XYZ,tp)
end

function s.xyzop(e,tp,chk)
	if chk==0 then return not Duel.HasFlagEffect(tp,id) and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local sc=Duel.GetMatchingGroup(Card.IsDiscardable,tp,LOCATION_HAND,0,nil):SelectUnselect(Group.CreateGroup(),tp,false,Xyz.ProcCancellable)
	if sc and Duel.SendtoGrave(sc,REASON_DISCARD|REASON_COST)>0 then
		return Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,EFFECT_FLAG_OATH,1)
	else
		return false
	end
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
	if chk==0 then
		local c=e:GetHandler()
		local mat_ct=c:GetOverlayCount()
		return mat_ct>0 and c:CheckRemoveOverlayCard(tp,mat_ct,REASON_EFFECT)
			and #g>0
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,tp,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local exc=c:IsRelateToEffect(e) and c or nil
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,exc)
	local mg=c:GetOverlayGroup()
	if c:IsRelateToEffect(e) and #mg>0 and Duel.SendtoGrave(mg,REASON_EFFECT)>0 and #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
	--Your monsters cannot attack directly this turn
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE|PHASE_END,2)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(c,0,tp,1,0,aux.Stringid(id,2))
end

function s.atttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ) and Duel.GetFieldGroupCount(1-tp,LOCATION_DECK,0)>0 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
end

function s.attop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local b1=Duel.GetDecktopGroup(tp,1)
	local b2=Duel.GetDecktopGroup(1-tp,1)	
	if (b1 or b2) and c:IsRelateToEffect(e) then
		local op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,5)},
			{b2,aux.Stringid(id,6)})
		if op==1 and #b1==1 then
			--Attach the top card of your Deck to this card as material
			Duel.BreakEffect()
			Duel.DisableShuffleCheck()
			Duel.Overlay(c,b1)
		elseif op==2 and #b2==1 then
			--Attach the top card of your opponent's Deck to this card as material
			Duel.BreakEffect()
			Duel.DisableShuffleCheck()
			Duel.Overlay(c,b2)
		end
	end	
end

function s.damfilter(c)
	return c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end

function s.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.damfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.damfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end

function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,2700)
end

function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Damage(tp,2700,REASON_EFFECT,true)
	Duel.Damage(1-tp,2700,REASON_EFFECT,true)
	Duel.RDComplete()
end
