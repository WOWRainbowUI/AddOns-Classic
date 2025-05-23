
	local Details =	_G.Details
	local Loc = _G.LibStub("AceLocale-3.0"):GetLocale("Details")
	local libwindow = LibStub("LibWindow-1.1")
	local _

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--local pointers
	local floor = math.floor --lua local
	local type = type --lua local
	local abs = math.abs --lua local
	local _math_min = math.min
	local _math_max = math.max
	local ipairs = ipairs --lua local
	local gump = Details.gump --details local

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--constants
	local end_window_spacement = 0

--settings
	local animation_speed = 33
	local animation_speed_hightravel_trigger = 5
	local animation_speed_hightravel_maxspeed = 3
	local animation_speed_lowtravel_minspeed = 0.33
	local animation_func_left
	local animation_func_right

	gump:NewColor("DETAILS_API_ICON", .5, .4, .3, 1)
	gump:NewColor("DETAILS_STATISTICS_ICON", .8, .8, .8, 1)

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--core

	function Details:AnimarSplit(barra, goal)
		barra.inicio = barra.split.barra:GetValue()
		barra.fim = goal
		barra.proximo_update = 0
		barra.tem_animacao = true
		barra:SetScript("OnUpdate", self.FazerAnimacaoSplit)
	end

	function Details:FazerAnimacaoSplit(elapsed)
		local velocidade = 0.8

		if (self.fim > self.inicio) then
			self.inicio = self.inicio+velocidade
			self.split.barra:SetValue(self.inicio)

			self.split.div:SetPoint("left", self.split.barra, "left", self.split.barra:GetValue()* (self.split.barra:GetWidth()/100) - 4, 0)

			if (self.inicio+1 >= self.fim) then
				self.tem_animacao = false
				self:SetScript("OnUpdate", nil)
			end
		else
			self.inicio = self.inicio-velocidade
			self.split.barra:SetValue(self.inicio)

			self.split.div:SetPoint("left", self.split.barra, "left", self.split.barra:GetValue()* (self.split.barra:GetWidth()/100) - 4, 0)

			if (self.inicio-1 <= self.fim) then
				self.tem_animacao = false
				self:SetScript("OnUpdate", nil)
			end
		end
		self.proximo_update = 0
	end

	function Details:PerformAnimations(amtLines)
		if (self.bars_sort_direction == 2) then
			for i = _math_min(self.rows_fit_in_window, amtLines) - 1, 1, -1 do
				local row = self.barras [i]
				local row_proxima = self.barras [i-1]

				if (row_proxima and not row.animacao_ignorar) then
					local v = row.statusbar.value
					local v_proxima = row_proxima.statusbar.value

					if (v_proxima > v) then
						if (row.animacao_fim >= v_proxima) then
							row:SetValue(v_proxima)
						else
							row:SetValue(row.animacao_fim)
							row_proxima.statusbar:SetValue(row.animacao_fim)
						end
					end
				end
			end

			for i = 1, self.rows_fit_in_window -1 do
				local row = self.barras [i]
				if (row.animacao_ignorar) then
					row.animacao_ignorar = nil
					if (row.tem_animacao) then
						row.tem_animacao = false
						row:SetScript("OnUpdate", nil)
					end
				else
					if (row.animacao_fim ~= row.animacao_fim2) then
						Details:AnimarBarra (row, row.animacao_fim)
						row.animacao_fim2 = row.animacao_fim
					end
				end
			end
		else
			for i = 2, self.rows_fit_in_window do
				local row = self.barras [i]
				local row_proxima = self.barras [i+1]

				if (row_proxima and not row.animacao_ignorar) then
					local v = row.statusbar.value
					local v_proxima = row_proxima.statusbar.value

					if (v_proxima > v) then
						if (row.animacao_fim >= v_proxima) then
							row:SetValue(v_proxima)
						else
							row:SetValue(row.animacao_fim)
							row_proxima.statusbar:SetValue(row.animacao_fim)
						end
					end
				end
			end

			for i = 2, self.rows_fit_in_window do
				local row = self.barras [i]
				if (row.animacao_ignorar) then
					row.animacao_ignorar = nil
					if (row.tem_animacao) then
						row.tem_animacao = false
						row:SetScript("OnUpdate", nil)
					end
				else
					if (row.animacao_fim ~= row.animacao_fim2) then
						Details:AnimarBarra (row, row.animacao_fim)
						row.animacao_fim2 = row.animacao_fim
					end
				end
			end
		end

	end

	--simple left and right animations by delta time
	local animation_left_simple = function(self, deltaTime)
		self.inicio = self.inicio - (animation_speed * deltaTime)
		self:SetValue(self.inicio)
		if (self.inicio-1 <= self.fim) then
			self.tem_animacao = false
			self:SetScript("OnUpdate", nil)
		end
	end

	local animation_right_simple = function(self, deltaTime)
		self.inicio = self.inicio + (animation_speed * deltaTime)
		self:SetValue(self.inicio)
		if (self.inicio+0.1 >= self.fim) then
			self.tem_animacao = false
			self:SetScript("OnUpdate", nil)
		end
	end

	--animation with acceleration
	local animation_left_with_accel = function(self, deltaTime)
		local distance = self.inicio - self.fim

		-- DefaultSpeed * max of ( min of (Distance / TriggerSpeed , MaxSpeed) , LowSpeed )
		local calcAnimationSpeed = animation_speed * _math_max (_math_min(distance/animation_speed_hightravel_trigger, animation_speed_hightravel_maxspeed), animation_speed_lowtravel_minspeed)

		self.inicio = self.inicio - (calcAnimationSpeed * deltaTime)
		self:SetValue(self.inicio)
		if (self.inicio-0.1 <= self.fim) then
			self.tem_animacao = false
			self:SetScript("OnUpdate", nil)
		end
	end

	local animation_right_with_accel = function(self, deltaTime)
		local distance = self.fim - self.inicio
		local calcAnimationSpeed = animation_speed * _math_max (_math_min(distance/animation_speed_hightravel_trigger, animation_speed_hightravel_maxspeed), animation_speed_lowtravel_minspeed)

		self.inicio = self.inicio + (calcAnimationSpeed * deltaTime)
		self:SetValue(self.inicio)
		if (self.inicio+0.1 >= self.fim) then
			self.tem_animacao = false
			self:SetScript("OnUpdate", nil)
		end
	end

	--initiate with defaults
	animation_func_left  = animation_left_simple
	animation_func_right = animation_right_simple

	function Details:AnimarBarra (esta_barra, fim)
		esta_barra.inicio = esta_barra.statusbar.value
		esta_barra.fim = fim
		esta_barra.tem_animacao = true

		if (esta_barra.fim > esta_barra.inicio) then
			esta_barra:SetScript("OnUpdate", animation_func_right)
		else
			esta_barra:SetScript("OnUpdate", animation_func_left)
		end
	end

	function Details:RefreshAnimationFunctions()
		if (Details.streamer_config.use_animation_accel) then
			animation_func_left  = animation_left_with_accel
			animation_func_right = animation_right_with_accel

		else
			animation_func_left  = animation_left_simple
			animation_func_right = animation_right_simple
		end

		animation_speed = Details.animation_speed
		animation_speed_hightravel_trigger = Details.animation_speed_triggertravel
		animation_speed_hightravel_maxspeed = Details.animation_speed_maxtravel
		animation_speed_lowtravel_minspeed = Details.animation_speed_mintravel
	end

	--deprecated
	function Details:FazerAnimacao_Esquerda (deltaTime)
		self.inicio = self.inicio - (animation_speed * deltaTime)
		self:SetValue(self.inicio)
		if (self.inicio-1 <= self.fim) then
			self.tem_animacao = false
			self:SetScript("OnUpdate", nil)
		end
	end

	function Details:FazerAnimacao_Direita (deltaTime)
		self.inicio = self.inicio + (animation_speed * deltaTime)
		self:SetValue(self.inicio)
		if (self.inicio+0.1 >= self.fim) then
			self.tem_animacao = false
			self:SetScript("OnUpdate", nil)
		end
	end

	function Details:AtualizaPontos()
		local _x, _y = self:GetPositionOnScreen()
		if (not _x) then
 			return
 		end

		local _w, _h = self:GetRealSize()

		local metade_largura = _w/2
		local metade_altura = _h/2

		local statusbar_y_mod = 0
		if (not self.show_statusbar) then
			statusbar_y_mod = 14 * self.baseframe:GetScale()
		end

		if (not self.ponto1) then
			self.ponto1 = {x = _x - metade_largura, y = _y + metade_altura + (statusbar_y_mod*-1)} --topleft
			self.ponto2 = {x = _x - metade_largura, y = _y - metade_altura + statusbar_y_mod} --bottomleft
			self.ponto3 = {x = _x + metade_largura, y = _y - metade_altura + statusbar_y_mod} --bottomright
			self.ponto4 = {x = _x + metade_largura, y = _y + metade_altura + (statusbar_y_mod*-1)} --topright
		else
			self.ponto1.x = _x - metade_largura
			self.ponto1.y = _y + metade_altura + (statusbar_y_mod*-1)
			self.ponto2.x = _x - metade_largura
			self.ponto2.y = _y - metade_altura + statusbar_y_mod
			self.ponto3.x = _x + metade_largura
			self.ponto3.y = _y - metade_altura + statusbar_y_mod
			self.ponto4.x = _x + metade_largura
			self.ponto4.y = _y + metade_altura + (statusbar_y_mod*-1)
		end

	end

--------------------------------------------------------------------------------------------------------

	--LibWindow-1.1 by Mikk http://www.wowace.com/profiles/mikk/
	--this is the restore function from Libs\LibWindow-1.1\LibWindow-1.1.lua.
	--we can't schedule a new save after restoring, we save it inside the instance without frame references and always attach to UIparent.
	function Details:RestoreLibWindow()
		local frame = self.baseframe
		if (frame) then
			if (self.libwindow.x) then

				local x = self.libwindow.x
				local y = self.libwindow.y
				local point = self.libwindow.point
				local s = self.libwindow.scale

				if s then
					(frame.lw11origSetScale or frame.SetScale)(frame,s)
				else
					s = frame:GetScale()
				end

				if not x or not y then		-- nothing stored in config yet, smack it in the center
					x=0; y=0; point="CENTER"
				end

				x = x/s
				y = y/s

				frame:ClearAllPoints()
				if not point and y==0 then	-- errr why did i do this check again? must have been a reason, but i can't remember it =/
					point="CENTER"
				end

				--Details: using UIParent always in order to not break the positioning when using AddonSkin with ElvUI.
				if not point then	-- we have position, but no point, which probably means we're going from data stored by the addon itself before LibWindow was added to it. It was PROBABLY topleft->bottomleft anchored. Most do it that way.
					frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y) --frame:SetPoint("TOPLEFT", frame:GetParent(), "BOTTOMLEFT", x, y)
					-- make it compute a better attachpoint (on next update)
					--_detalhes:ScheduleTimer("SaveLibWindow", 0.05, self)
					return
				end

				frame:SetPoint(point, UIParent, point, x, y)

			end
		end
	end

	--LibWindow-1.1 by Mikk http://www.wowace.com/profiles/mikk/
	--this is the save function from Libs\LibWindow-1.1\LibWindow-1.1.lua.
	--we need to make it save inside the instance object without frame references and also we must always use UIParent due to embed settings for ElvUI and LUI.

		function Details:SaveLibWindow()
			local frame = self.baseframe
			if (frame) then
				local left = frame:GetLeft()
				if (not left) then
					return Details:ScheduleTimer("SaveLibWindow", 0.05, self)
				end
					--Details: we are always using UIParent here or the addon break when using Embeds.
					local parent = UIParent --local parent = frame:GetParent() or nilParent
					-- No, this won't work very well with frames that aren't parented to nil or UIParent
					local s = frame:GetScale()
					local left,top = frame:GetLeft()*s, frame:GetTop()*s
					local right,bottom = frame:GetRight()*s, frame:GetBottom()*s
					local pwidth, pheight = parent:GetWidth(), parent:GetHeight()

					local x,y,point;
					if left < (pwidth-right) and left < abs((left+right)/2 - pwidth/2) then
						x = left;
						point="LEFT";
					elseif (pwidth-right) < abs((left+right)/2 - pwidth/2) then
						x = right-pwidth;
						point="RIGHT";
					else
						x = (left+right)/2 - pwidth/2;
						point="";
					end

					if bottom < (pheight-top) and bottom < abs((bottom+top)/2 - pheight/2) then
						y = bottom;
						point="BOTTOM"..point;
					elseif (pheight-top) < abs((bottom+top)/2 - pheight/2) then
						y = top-pheight;
						point="TOP"..point;
					else
						y = (bottom+top)/2 - pheight/2;
						-- point=""..point;
					end

					if point=="" then
						point = "CENTER"
					end

				----------------------------------------
				--save inside the instance object
				self.libwindow.x = x
				self.libwindow.y = y
				self.libwindow.point = point
				self.libwindow.scale = s
			end
		end

	--end for libwindow-1.1
--------------------------------------------------------------------------------------------------------

	function Details:SaveMainWindowSize()
		local baseframe_width = self.baseframe:GetWidth()
		if (not baseframe_width) then
			return Details:ScheduleTimer("SaveMainWindowSize", 1, self)
		end
		local baseframe_height = self.baseframe:GetHeight()

		--calc position
		local _x, _y = self:GetPositionOnScreen()
		if (not _x) then
 			return Details:ScheduleTimer("SaveMainWindowSize", 1, self)
 		end

		--save the position
		local _w = baseframe_width
		local _h = baseframe_height

		local mostrando = self.mostrando

		self.posicao[mostrando].x = _x
		self.posicao[mostrando].y = _y
		self.posicao[mostrando].w = _w
		self.posicao[mostrando].h = _h

		--update the 4 points for window groups
		local metade_largura = _w/2
		local metade_altura = _h/2

		local statusbar_y_mod = 0
		if (not self.show_statusbar) then
			statusbar_y_mod = 14 * self.baseframe:GetScale()
		end

		if (not self.ponto1) then
			self.ponto1 = {x = _x - metade_largura, y = _y + metade_altura + (statusbar_y_mod*-1)} --topleft
			self.ponto2 = {x = _x - metade_largura, y = _y - metade_altura + statusbar_y_mod} --bottomleft
			self.ponto3 = {x = _x + metade_largura, y = _y - metade_altura + statusbar_y_mod} --bottomright
			self.ponto4 = {x = _x + metade_largura, y = _y + metade_altura + (statusbar_y_mod*-1)} --topright
		else
			self.ponto1.x = _x - metade_largura
			self.ponto1.y = _y + metade_altura + (statusbar_y_mod*-1)
			self.ponto2.x = _x - metade_largura
			self.ponto2.y = _y - metade_altura + statusbar_y_mod
			self.ponto3.x = _x + metade_largura
			self.ponto3.y = _y - metade_altura + statusbar_y_mod
			self.ponto4.x = _x + metade_largura
			self.ponto4.y = _y + metade_altura + (statusbar_y_mod*-1)
		end

		self.baseframe.BoxBarrasAltura = self.baseframe:GetHeight() - end_window_spacement --espa�o para o final da janela

		return {altura = self.baseframe:GetHeight(), largura = self.baseframe:GetWidth(), x = _x, y = _y}
	end

	function Details:SaveMainWindowPosition (instance)
		if (instance) then
			self = instance
		end
		local mostrando = self.mostrando

		--get sizes
		local baseframe_width = self.baseframe:GetWidth()
		if (not baseframe_width) then
			return Details:ScheduleTimer("SaveMainWindowPosition", 1, self)
		end
		local baseframe_height = self.baseframe:GetHeight()

		--calc position
		local _x, _y = self:GetPositionOnScreen()
		if (not _x) then
 			return Details:ScheduleTimer("SaveMainWindowPosition", 1, self)
 		end

		if (self.mostrando ~= "solo") then
			self:SaveLibWindow()
		end

		--save the position
		local _w = baseframe_width
		local _h = baseframe_height

		self.posicao[mostrando].x = _x
		self.posicao[mostrando].y = _y
		self.posicao[mostrando].w = _w
		self.posicao[mostrando].h = _h

		--update the 4 points for window groups
		local metade_largura = _w/2
		local metade_altura = _h/2

		local statusbar_y_mod = 0
		if (not self.show_statusbar) then
			statusbar_y_mod = 14 * self.baseframe:GetScale()
		end

		if (not self.ponto1) then
			self.ponto1 = {x = _x - metade_largura, y = _y + metade_altura + (statusbar_y_mod*-1)} --topleft
			self.ponto2 = {x = _x - metade_largura, y = _y - metade_altura + statusbar_y_mod} --bottomleft
			self.ponto3 = {x = _x + metade_largura, y = _y - metade_altura + statusbar_y_mod} --bottomright
			self.ponto4 = {x = _x + metade_largura, y = _y + metade_altura + (statusbar_y_mod*-1)} --topright
		else
			self.ponto1.x = _x - metade_largura
			self.ponto1.y = _y + metade_altura + (statusbar_y_mod*-1)
			self.ponto2.x = _x - metade_largura
			self.ponto2.y = _y - metade_altura + statusbar_y_mod
			self.ponto3.x = _x + metade_largura
			self.ponto3.y = _y - metade_altura + statusbar_y_mod
			self.ponto4.x = _x + metade_largura
			self.ponto4.y = _y + metade_altura + (statusbar_y_mod*-1)
		end

		self.baseframe.BoxBarrasAltura = self.baseframe:GetHeight() - end_window_spacement --espa�o para o final da janela

		return {altura = self.baseframe:GetHeight(), largura = self.baseframe:GetWidth(), x = _x, y = _y}
	end

	function Details:RestoreMainWindowPosition (pre_defined)
		if (not pre_defined and self.libwindow.x and self.mostrando == "normal" and not Details.instances_no_libwindow) then
			local s = self.window_scale
			self.baseframe:SetScale(s)
			self.rowframe:SetScale(s)

			self.baseframe:SetWidth(self.posicao[self.mostrando].w)
			self.baseframe:SetHeight(self.posicao[self.mostrando].h)

			self:RestoreLibWindow()
			self.baseframe.BoxBarrasAltura = self.baseframe:GetHeight() - end_window_spacement --espa�o para o final da janela
			return
		end

		local s = self.window_scale
		self.baseframe:SetScale(s)
		self.rowframe:SetScale(s)

		local _scale = self.baseframe:GetEffectiveScale()
		local _UIscale = UIParent:GetScale()

		local novo_x = self.posicao[self.mostrando].x*_UIscale/_scale
		local novo_y = self.posicao[self.mostrando].y*_UIscale/_scale

		if (pre_defined and pre_defined.x) then --overwrite
			novo_x = pre_defined.x*_UIscale/_scale
			novo_y = pre_defined.y*_UIscale/_scale
			self.posicao[self.mostrando].w = pre_defined.largura
			self.posicao[self.mostrando].h = pre_defined.altura

		elseif (pre_defined and not pre_defined.x) then
			Details:Msg(Loc["invalid pre_defined table for resize, please rezise the window manually."])
		end

		self.baseframe:SetWidth(self.posicao[self.mostrando].w)
		self.baseframe:SetHeight(self.posicao[self.mostrando].h)

		self.baseframe:ClearAllPoints()
		self.baseframe:SetPoint("CENTER", UIParent, "CENTER", novo_x, novo_y)
	end

	function Details:RestoreMainWindowPositionNoResize (pre_defined, x, y)
		x = x or 0
		y = y or 0

		local _scale = self.baseframe:GetEffectiveScale()
		local _UIscale = UIParent:GetScale()

		local novo_x = self.posicao[self.mostrando].x*_UIscale/_scale
		local novo_y = self.posicao[self.mostrando].y*_UIscale/_scale

		if (pre_defined) then --overwrite
			novo_x = pre_defined.x*_UIscale/_scale
			novo_y = pre_defined.y*_UIscale/_scale
			self.posicao[self.mostrando].w = pre_defined.largura
			self.posicao[self.mostrando].h = pre_defined.altura
		end

		self.baseframe:ClearAllPoints()
		self.baseframe:SetPoint("CENTER", UIParent, "CENTER", novo_x + x, novo_y + y)
		self.baseframe.BoxBarrasAltura = self.baseframe:GetHeight() - end_window_spacement --espa�o para o final da janela
	end

	function Details:CreatePositionTable()
		local t = {pos_table = true}

		if (self.libwindow) then
			t.x = self.libwindow.x
			t.y = self.libwindow.y
			t.scale = self.libwindow.scale
			t.point = self.libwindow.point
		end

		--old way to save positions
		t.x_legacy = self.posicao.normal.x
		t.y_legacy = self.posicao.normal.y

		--size
		t.w = self.posicao.normal.w
		t.h = self.posicao.normal.h

		return t
	end

	function Details:RestorePositionFromPositionTable (t)
		if (not t.pos_table) then
			return
		end

		if (t.x) then
			self.libwindow.x = t.x
			self.libwindow.y = t.y
			self.libwindow.scale = t.scale
			self.libwindow.point = t.point
		end

		self.posicao.normal.x = t.x_legacy
		self.posicao.normal.y = t.y_legacy

		self.posicao.normal.w = t.w
		self.posicao.normal.h = t.h

		return self:RestoreMainWindowPosition()
	end

	function Details:ResetaGump (instancia, tipo, segmento) --replaced by instance:ResetWindow(resetType, segmentId)
		if (not instancia or type(instancia) == "boolean") then
			segmento = tipo
			tipo = instancia
			instancia = self
		end

		if (tipo and tipo == 0x1) then --entrando em combate
			if (instancia.segmento == -1) then --esta mostrando a tabela overall
				return
			end
		end

		if (segmento and instancia.segmento ~= segmento) then
			return
		end

		instancia.barraS = {nil, nil} --zera o iterator
		instancia.rows_showing = 0 --resetou, ent�o n�o esta mostranho nenhuma barra

		for i = 1, instancia.rows_created, 1 do --limpa a refer�ncia do que estava sendo mostrado na barra
			local esta_barra= instancia.barras[i]
			esta_barra.minha_tabela = nil
			esta_barra.animacao_fim = 0
			esta_barra.animacao_fim2 = 0
			if esta_barra.extraStatusbar then esta_barra.extraStatusbar:Hide() end
		end

		if (instancia.rolagem) then
			instancia:EsconderScrollBar() --hida a scrollbar
		end
		instancia.need_rolagem = false
		instancia.bar_mod = nil
	end

	function Details:ReajustaGump()
		if (self.mostrando == "normal") then --somente alterar o tamanho das barras se tiver mostrando o gump normal
			if (not self.baseframe.isStretching and self.stretchToo and #self.stretchToo > 0) then
				if (self.eh_horizontal or self.eh_tudo or (self.verticalSnap and not self.eh_vertical)) then
					for _, instancia in ipairs(self.stretchToo) do
						instancia.baseframe:SetWidth(self.baseframe:GetWidth())
						local mod = (self.baseframe:GetWidth() - instancia.baseframe._place.largura) / 2
						instancia:RestoreMainWindowPositionNoResize(instancia.baseframe._place, mod, nil)
						instancia:BaseFrameSnap()
					end
				end

				if ((self.eh_vertical or self.eh_tudo or not self.eh_horizontal) and (not self.verticalSnap or self.eh_vertical)) then
					for _, instancia in ipairs(self.stretchToo) do
						if (instancia.baseframe) then --esta criada
							instancia.baseframe:SetHeight(self.baseframe:GetHeight())
							local mod
							if (self.eh_vertical) then
								mod = (self.baseframe:GetHeight() - instancia.baseframe._place.altura) / 2
							else
								mod = - (self.baseframe:GetHeight() - instancia.baseframe._place.altura) / 2
							end
							instancia:RestoreMainWindowPositionNoResize(instancia.baseframe._place, nil, mod)
							instancia:BaseFrameSnap()
						end
					end
				end

			elseif (self.baseframe.isStretching and self.stretchToo and #self.stretchToo > 0) then
				if (self.baseframe.stretch_direction == "top") then
					for _, instancia in ipairs(self.stretchToo) do
						instancia.baseframe:SetHeight(self.baseframe:GetHeight())
						local mod = (self.baseframe:GetHeight() - (instancia.baseframe._place.altura or instancia.baseframe:GetHeight())) / 2
						instancia:RestoreMainWindowPositionNoResize(instancia.baseframe._place, nil, mod)
					end

				elseif (self.baseframe.stretch_direction == "bottom") then
					for _, instancia in ipairs(self.stretchToo) do
						instancia.baseframe:SetHeight(self.baseframe:GetHeight())
						local mod = (self.baseframe:GetHeight() - instancia.baseframe._place.altura) / 2
						mod = mod * -1
						instancia:RestoreMainWindowPositionNoResize(instancia.baseframe._place, nil, mod)
					end
				end
			end

			if (self.stretch_button_side == 2) then
				self:StretchButtonAnchor(2)
			end

			--reajusta o freeze
			if (self.freezed) then
				Details:Freeze(self)
			end

			-- -4 difere a precis�o de quando a barra ser� adicionada ou apagada da barra
			self.baseframe.BoxBarrasAltura = (self.baseframe:GetHeight()) - end_window_spacement

			local T = self.rows_fit_in_window
			if (not T) then --primeira vez que o gump esta sendo reajustado
				T = floor(self.baseframe.BoxBarrasAltura / self.row_height)
			end

			--reajustar o local do rel�gio
			local meio = self.baseframe:GetWidth() / 2
			local novo_local = meio - 25

			self.rows_fit_in_window = floor(self.baseframe.BoxBarrasAltura / self.row_height)

			--verifica se precisa criar mais barras
			if (self.rows_fit_in_window > #self.barras) then--verifica se precisa criar mais barras
				for i  = #self.barras+1, self.rows_fit_in_window, 1 do
					gump:CreateNewLine(self, i) --cria nova barra
				end
				self.rows_created = #self.barras
			end

			--faz um cache do tamanho das barras
			self.cached_bar_width = self.barras[1] and self.barras[1]:GetWidth() or 0

			--seta a largura das barras
			if (self.bar_mod and self.bar_mod ~= 0) then
				for index = 1, self.rows_fit_in_window do
					if (self.barras[index]) then
						self.barras[index]:SetWidth(self.baseframe:GetWidth()+self.bar_mod)
					end
				end
			else
				local rightOffset = self.row_info.row_offsets.right
				for index = 1, self.rows_fit_in_window do
					if (self.barras[index]) then
						self.barras[index]:SetWidth(self.baseframe:GetWidth()+self.row_info.space.right + rightOffset)
					end
				end
			end

			--verifica se precisa esconder ou mostrar alguma barra
			local A = self.barraS[1]
			if (not A) then --primeira vez que o resize esta sendo usado, no caso no startup do addon ou ao criar uma nova inst�ncia
				--hida as barras n�o usadas
				for i = 1, self.rows_created, 1 do
					Details.FadeHandler.Fader(self.barras[i], 1)
					self.barras[i].on = false
				end
				return
			end

			local X = self.rows_showing
			local C = self.rows_fit_in_window

			--novo iterator
			local barras_diff = C - T --aqui pega a quantidade de barras, se aumentou ou diminuiu
			if (barras_diff > 0) then --ganhou barras_diff novas barras
				local fim_iterator = self.barraS[2] --posi��o atual
				fim_iterator = fim_iterator+barras_diff --nova posi��o
				local excedeu_iterator = fim_iterator - X --total que ta sendo mostrado - fim do iterator

				if (excedeu_iterator > 0) then --extrapolou
					fim_iterator = X --seta o fim do iterator pra ser na ultima barra
					self.barraS[2] = fim_iterator --fim do iterator setado

					local inicio_iterator = self.barraS[1]
					if (inicio_iterator-excedeu_iterator > 0) then --se as barras que sobraram preenchem o inicio do iterator
						inicio_iterator = inicio_iterator-excedeu_iterator --pega o novo valor do iterator
						self.barraS[1] = inicio_iterator
					else
						self.barraS[1] = 1 --se ganhou mais barras pra cima, ignorar elas e mover o iterator para a poci��o inicial
					end
				else
					--se n�o extrapolou esta okey e esta mostrando a quantidade de barras correta
					self.barraS[2] = fim_iterator
				end

				for index = T+1, C do
					local barra = self.barras[index]
					if (barra) then
						if (index <= X) then
							--Details.FadeHandler.Fader(barra, 0)
							Details.FadeHandler.Fader(barra, "out")
						else
							--if (self.baseframe.isStretching or self.auto_resize) then
								Details.FadeHandler.Fader(barra, 1)
							--else
							--	Details.FadeHandler.Fader(barra, 1)
							--end
						end
					end
				end

			elseif (barras_diff < 0) then --perdeu barras_diff barras
				local fim_iterator = self.barraS[2] --posi��o atual
				if (not (fim_iterator == X and fim_iterator < C)) then --calcula primeiro as barras que foram perdidas s�o barras que n�o estavam sendo usadas
					--perdi X barras, diminui X posi��es no iterator
					local perdeu = abs(barras_diff)

					if (fim_iterator == X) then --se o iterator tiver na ultima posi��o
						perdeu = perdeu - (C - X)
					end

					fim_iterator = fim_iterator - perdeu

					if (fim_iterator < C) then
						fim_iterator = C
					end

					self.barraS[2] = fim_iterator

					for index = T, C+1, -1 do
						local barra = self.barras[index]
						if (barra) then
							if (self.baseframe.isStretching or self.auto_resize) then
								Details.FadeHandler.Fader(barra, 1)
							else
								--Details.FadeHandler.Fader(barra, "in", 0.1)
								Details.FadeHandler.Fader(barra, 1)
							end
						end
					end
				end
			end

			if (X <= C) then --desligar a rolagem
				if (self.rolagem and not self.baseframe.isStretching) then
					self:EsconderScrollBar()
				end
				self.need_rolagem = false

			else --ligar ou atualizar a rolagem
				if (not self.rolagem and not self.baseframe.isStretching) then
					self:MostrarScrollBar()
				end
				self.need_rolagem = true
			end

			--verificar o tamanho dos nomes
			local whichRowLine = 1
			for i = self.barraS[1], self.barraS[2], 1 do
				local esta_barra = self.barras [whichRowLine]
				local tabela = esta_barra.minha_tabela

				if (tabela) then --a barra esta mostrando alguma coisa
					if (tabela._custom) then
						tabela (esta_barra, self)
					elseif (tabela._refresh_window) then
						tabela:_refresh_window(esta_barra, self)
					else
						tabela:RefreshBarra(esta_barra, self, true)
					end
				end

				whichRowLine = whichRowLine+1
			end

			--for�a o pr�ximo refresh
			self.showing[self.atributo].need_refresh = true
		end
	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--panels

--cooltip presets
	local preset3_backdrop = {bgFile = [[Interface\DialogFrame\UI-DialogBox-Background-Dark]], edgeFile = [[Interface\AddOns\Details\images\border_3]], tile=true,
	edgeSize = 16, tileSize = 64, insets = {left = 3, right = 3, top = 4, bottom = 4}}

	Details.cooltip_preset3_backdrop = preset3_backdrop

	local white_table = {1, 1, 1, 1}
	local black_table = {0, 0, 0, 1}
	local gray_table = {0.37, 0.37, 0.37, 0.95}

	local preset2_backdrop = {bgFile = [[Interface\AddOns\Details\images\background]], edgeFile = [[Interface\Buttons\WHITE8X8]], tile=true,
	edgeSize = 1, tileSize = 64, insets = {left = 0, right = 0, top = 0, bottom = 0}}
	Details.cooltip_preset2_backdrop = preset2_backdrop

	--"Details BarBorder 3"
	function Details:CooltipPreset(preset)
		local GameCooltip = GameCooltip

		GameCooltip:Reset()

		if (preset == 1) then
			GameCooltip:SetOption("TextFont", "Friz Quadrata TT")
			GameCooltip:SetOption("TextColor", "orange")
			GameCooltip:SetOption("TextSize", 16)
			GameCooltip:SetOption("ButtonsYMod", -4)
			GameCooltip:SetOption("YSpacingMod", -4)
			GameCooltip:SetOption("IgnoreButtonAutoHeight", true)
			GameCooltip:SetColor (1, 0.5, 0.5, 0.5, 0.5)

		elseif (preset == 2) then
			GameCooltip:SetOption("TextFont", "Friz Quadrata TT")
			GameCooltip:SetOption("TextColor", "orange")
			GameCooltip:SetOption("TextSize", 16)
			GameCooltip:SetOption("FixedWidth", 220)
			GameCooltip:SetOption("ButtonsYMod", -4)
			GameCooltip:SetOption("YSpacingMod", -4)
			GameCooltip:SetOption("IgnoreButtonAutoHeight", true)
			GameCooltip:SetColor (1, 0, 0, 0, 0)

			GameCooltip:SetOption("LeftBorderSize", -5)
			GameCooltip:SetOption("RightBorderSize", 5)

			GameCooltip:SetBackdrop(1, preset2_backdrop, gray_table, black_table)

		elseif (preset == 2.1) then
			GameCooltip:SetOption("TextFont", "Friz Quadrata TT")
			GameCooltip:SetOption("TextColor", "orange")
			GameCooltip:SetOption("TextSize", 14)
			GameCooltip:SetOption("FixedWidth", 220)
			GameCooltip:SetOption("ButtonsYMod", 0)
			GameCooltip:SetOption("YSpacingMod", -4)
			GameCooltip:SetOption("IgnoreButtonAutoHeight", true)
			GameCooltip:SetColor (1, 0, 0, 0, 0)

			GameCooltip:SetBackdrop(1, preset2_backdrop, gray_table, black_table)

		elseif (preset == 3) then
			GameCooltip:SetOption("TextFont", "Friz Quadrata TT")
			GameCooltip:SetOption("TextColor", "orange")
			GameCooltip:SetOption("TextSize", 16)
			GameCooltip:SetOption("FixedWidth", 220)
			GameCooltip:SetOption("ButtonsYMod", -4)
			GameCooltip:SetOption("YSpacingMod", -4)
			GameCooltip:SetOption("IgnoreButtonAutoHeight", true)
			GameCooltip:SetColor (1, 0.5, 0.5, 0.5, 0.5)

			GameCooltip:SetBackdrop(1, preset3_backdrop, nil, white_table)
		end
	end

--yes no panel

	do
		Details.yesNo = Details.gump:NewPanel(UIParent, _, "DetailsYesNoWindow", _, 500, 80)
		Details.yesNo:SetPoint("center", UIParent, "center")
		Details.gump:NewLabel(Details.yesNo, _, "$parentAsk", "ask", "")
		Details.yesNo ["ask"]:SetPoint("center", Details.yesNo, "center", 0, 25)
		Details.yesNo ["ask"]:SetWidth(480)
		Details.yesNo ["ask"]:SetJustifyH("center")
		Details.yesNo ["ask"]:SetHeight(22)
		Details.gump:NewButton(Details.yesNo, _, "$parentNo", "no", 100, 30, function() Details.yesNo:Hide() end, nil, nil, nil, Loc ["STRING_NO"])
		Details.gump:NewButton(Details.yesNo, _, "$parentYes", "yes", 100, 30, nil, nil, nil, nil, Loc ["STRING_YES"])
		Details.yesNo ["no"]:SetPoint(10, -45)
		Details.yesNo ["yes"]:SetPoint(390, -45)
		Details.yesNo ["no"]:InstallCustomTexture()
		Details.yesNo ["yes"]:InstallCustomTexture()
		Details.yesNo ["yes"]:SetHook("OnMouseUp", function() Details.yesNo:Hide() end)
		function Details:Ask (msg, func, ...)
			Details.yesNo ["ask"].text = msg
			local p1, p2 = ...
			Details.yesNo ["yes"]:SetClickFunction(func, p1, p2)
			Details.yesNo:Show()
		end
		Details.yesNo:Hide()
	end

--cria o frame de wait for plugin
	function Details:CreateWaitForPlugin()
		local WaitForPluginFrame = CreateFrame("frame", "DetailsWaitForPluginFrame" .. self.meu_id, UIParent,"BackdropTemplate")
		local WaitTexture = WaitForPluginFrame:CreateTexture(nil, "overlay")
		WaitTexture:SetTexture("Interface\\CHARACTERFRAME\\Disconnect-Icon")
		WaitTexture:SetWidth(64/2)
		WaitTexture:SetHeight(64/2)
		--WaitTexture:SetDesaturated(true)
		--WaitTexture:SetVertexColor(1, 1, 1, 0.3)
		WaitForPluginFrame.wheel = WaitTexture
		local RotateAnimGroup = WaitForPluginFrame:CreateAnimationGroup()
		local rotate = RotateAnimGroup:CreateAnimation("Alpha")
		--rotate:SetDegrees(360)
		--rotate:SetDuration(5)
		rotate:SetFromAlpha(0.8)
		rotate:SetToAlpha(1)
		--RotateAnimGroup:SetLooping ("repeat")
		rotate:SetTarget(WaitTexture)

		local bgpanel = gump:NewPanel(WaitForPluginFrame, WaitForPluginFrame, "DetailsWaitFrameBG"..self.meu_id, nil, 120, 30, false, false, false)
		bgpanel:SetPoint("center", WaitForPluginFrame, "center")
		bgpanel:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background"})
		bgpanel:SetBackdropColor(.2, .2, .2, 1)

		local label = gump:NewLabel(bgpanel, bgpanel, nil, nil, Loc ["STRING_WAITPLUGIN"])
		label.color = "white"
		label:SetPoint("center", WaitForPluginFrame, "center")
		label:SetJustifyH("left")
		label:Hide()
		WaitTexture:SetPoint("right", label.widget, "topleft", 12, -7)

		WaitForPluginFrame:Hide()
		self.wait_for_plugin_created = true

		function self:WaitForPlugin()
			self:ChangeIcon ([[Interface\GossipFrame\ActiveQuestIcon]])

			--if (WaitForPluginFrame:IsShown() and WaitForPluginFrame:GetParent() == self.baseframe) then
			--	self.waiting_pid = self:ScheduleTimer("ExecDelayedPlugin1", 5, self)
			--end

			WaitForPluginFrame:SetParent(self.baseframe)
			WaitForPluginFrame:SetAllPoints(self.baseframe)
			bgpanel:ClearAllPoints()
			bgpanel:SetPoint("topleft", self.baseframe, 0, 0)
			bgpanel:SetPoint("bottomright", self.baseframe, 0, 0)

			--local size = math.max(self.baseframe:GetHeight()* 0.35, 100)
			--WaitForPluginFrame.wheel:SetWidth(size)
			--WaitForPluginFrame.wheel:SetHeight(size)
			WaitForPluginFrame:Show()
			label:Show()
			bgpanel:Show()
			RotateAnimGroup:Play()

			self.waiting_raid_plugin = true

			self.waiting_pid = self:ScheduleTimer("ExecDelayedPlugin1", 5, self)
		end

		function self:CancelWaitForPlugin()
			RotateAnimGroup:Stop()
			WaitForPluginFrame:Hide()
			label:Hide()
			bgpanel:Hide()
		end

		function self:ExecDelayedPlugin1()

			self.waiting_raid_plugin = nil
			self.waiting_pid = nil

			RotateAnimGroup:Stop()
			WaitForPluginFrame:Hide()
			label:Hide()
			bgpanel:Hide()

			if (self.meu_id == Details.solo) then
				Details.SoloTables:switch(nil, Details.SoloTables.Mode)

			elseif (self.modo == Details._detalhes_props["MODO_RAID"]) then
				Details.RaidTables:EnableRaidMode (self)

			end
		end
	end

	do
		local WaitForPluginFrame = CreateFrame("frame", "DetailsWaitForPluginFrame", UIParent,"BackdropTemplate")
		local WaitTexture = WaitForPluginFrame:CreateTexture(nil, "overlay")
		WaitTexture:SetTexture("Interface\\UNITPOWERBARALT\\Mechanical_Circular_Frame")
		WaitTexture:SetPoint("center", WaitForPluginFrame)
		WaitTexture:SetWidth(180)
		WaitTexture:SetHeight(180)
		WaitForPluginFrame.wheel = WaitTexture
		local RotateAnimGroup = WaitForPluginFrame:CreateAnimationGroup()
		local rotate = RotateAnimGroup:CreateAnimation("Rotation")
		rotate:SetDegrees(360)
		rotate:SetDuration(60)
		RotateAnimGroup:SetLooping ("repeat")

		local bgpanel = gump:NewPanel(UIParent, UIParent, "DetailsWaitFrameBG", nil, 120, 30, false, false, false)
		bgpanel:SetPoint("center", WaitForPluginFrame, "center")
		bgpanel:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background"})
		bgpanel:SetBackdropColor(.2, .2, .2, 1)

		local label = gump:NewLabel(UIParent, UIParent, nil, nil, Loc ["STRING_WAITPLUGIN"]) --localize-me
		label.color = "silver"
		label:SetPoint("center", WaitForPluginFrame, "center")
		label:SetJustifyH("center")
		label:Hide()

		WaitForPluginFrame:Hide()

		function Details:WaitForSoloPlugin(instancia)
			instancia:ChangeIcon ([[Interface\GossipFrame\ActiveQuestIcon]])

			if (WaitForPluginFrame:IsShown() and WaitForPluginFrame:GetParent() == instancia.baseframe) then
				return Details:ScheduleTimer("ExecDelayedPlugin", 5, instancia)
			end

			WaitForPluginFrame:SetParent(instancia.baseframe)
			WaitForPluginFrame:SetAllPoints(instancia.baseframe)
			local size = math.max(instancia.baseframe:GetHeight()* 0.35, 100)
			WaitForPluginFrame.wheel:SetWidth(size)
			WaitForPluginFrame.wheel:SetHeight(size)
			WaitForPluginFrame:Show()
			label:Show()
			bgpanel:Show()
			RotateAnimGroup:Play()

			return Details:ScheduleTimer("ExecDelayedPlugin", 5, instancia)
		end

		function Details:CancelWaitForPlugin()
			RotateAnimGroup:Stop()
			WaitForPluginFrame:Hide()
			label:Hide()
			bgpanel:Hide()
		end

		function Details:ExecDelayedPlugin(instancia)
			RotateAnimGroup:Stop()
			WaitForPluginFrame:Hide()
			label:Hide()
			bgpanel:Hide()

			if (instancia.meu_id == Details.solo) then
				Details.SoloTables:switch(nil, Details.SoloTables.Mode)

			elseif (instancia.meu_id == Details.raid) then
				Details.RaidTables:switch(nil, Details.RaidTables.Mode)

			end
		end
	end

--feedback window
	function Details:OpenFeedbackWindow()
		if (not _G.DetailsFeedbackPanel) then

			gump:CreateSimplePanel(UIParent, 340, 300, Loc ["STRING_FEEDBACK_SEND_FEEDBACK"], "DetailsFeedbackPanel")
			local panel = _G.DetailsFeedbackPanel

			local label = gump:CreateLabel(panel, Loc ["STRING_FEEDBACK_PREFERED_SITE"])
			label:SetPoint("topleft", panel, "topleft", 15, -60)

			local wowi = gump:NewImage(panel, [[Interface\AddOns\Details\images\icons2]], 101, 34, "artwork", {0/512, 101/512, 163/512, 200/512})
			local curse = gump:NewImage(panel, [[Interface\AddOns\Details\images\icons2]], 101, 34, "artwork", {0/512, 101/512, 201/512, 242/512})
			local mmoc = gump:NewImage(panel, [[Interface\AddOns\Details\images\icons2]], 101, 34, "artwork", {0/512, 101/512, 243/512, 285/512})
			wowi:SetDesaturated(true)
			curse:SetDesaturated(true)
			mmoc:SetDesaturated(true)

			wowi:SetPoint("topleft", panel, "topleft", 17, -100)
			curse:SetPoint("topleft", panel, "topleft", 17, -160)
			mmoc:SetPoint("topleft", panel, "topleft", 17, -220)

			local wowi_title = gump:CreateLabel(panel, "Wow Interface:", nil, nil, "GameFontNormal")
			local wowi_desc = gump:CreateLabel(panel, Loc ["STRING_FEEDBACK_WOWI_DESC"], nil, "silver")
			wowi_desc:SetWidth(202)

			wowi_title:SetPoint("topleft", wowi, "topright", 5, 0)
			wowi_desc:SetPoint("topleft", wowi_title, "bottomleft", 0, -1)
			--
			local curse_title = gump:CreateLabel(panel, "Curse:", nil, nil, "GameFontNormal")
			local curse_desc = gump:CreateLabel(panel, Loc ["STRING_FEEDBACK_CURSE_DESC"], nil, "silver")
			curse_desc:SetWidth(202)

			curse_title:SetPoint("topleft", curse, "topright", 5, 0)
			curse_desc:SetPoint("topleft", curse_title, "bottomleft", 0, -1)
			--
			local mmoc_title = gump:CreateLabel(panel, "MMO-Champion:", nil, nil, "GameFontNormal")
			local mmoc_desc = gump:CreateLabel(panel, Loc ["STRING_FEEDBACK_MMOC_DESC"], nil, "silver")
			mmoc_desc:SetWidth(202)

			mmoc_title:SetPoint("topleft", mmoc, "topright", 5, 0)
			mmoc_desc:SetPoint("topleft", mmoc_title, "bottomleft", 0, -1)

			local on_enter = function(self, capsule)
				capsule.image:SetDesaturated(false)
			end
			local on_leave = function(self, capsule)
				capsule.image:SetDesaturated(true)
			end

			local on_click = function(_, _, website)
				if (website == 1) then
					Details:CopyPaste ([[http://www.wowinterface.com/downloads/addcomment.php?action=addcomment&fileid=23056]])

				elseif (website == 2) then
					Details:CopyPaste ([[http://www.curse.com/addons/wow/details]])

				elseif (website == 3) then
					Details:CopyPaste ([[http://www.mmo-champion.com/threads/1480721-New-damage-meter-%28Details!%29-need-help-with-tests-and-feedbacks]])

				end
			end

			local wowi_button = gump:CreateButton(panel, on_click, 103, 34, "", 1)
			wowi_button:SetPoint("topleft", wowi, "topleft", -1, 0)
			wowi_button:InstallCustomTexture (nil, nil, nil, nil, true)
			wowi_button.image = wowi
			wowi_button:SetHook("OnEnter", on_enter)
			wowi_button:SetHook("OnLeave", on_leave)

			local curse_button = gump:CreateButton(panel, on_click, 103, 34, "", 2)
			curse_button:SetPoint("topleft", curse, "topleft", -1, 0)
			curse_button:InstallCustomTexture (nil, nil, nil, nil, true)
			curse_button.image = curse
			curse_button:SetHook("OnEnter", on_enter)
			curse_button:SetHook("OnLeave", on_leave)

			local mmoc_button = gump:CreateButton(panel, on_click, 103, 34, "", 3)
			mmoc_button:SetPoint("topleft", mmoc, "topleft", -1, 0)
			mmoc_button:InstallCustomTexture (nil, nil, nil, nil, true)
			mmoc_button.image = mmoc
			mmoc_button:SetHook("OnEnter", on_enter)
			mmoc_button:SetHook("OnLeave", on_leave)

		end

		_G.DetailsFeedbackPanel:Show()
	end

	--interface menu
	local f = CreateFrame("frame", "DetailsInterfaceOptionsPanel", UIParent,"BackdropTemplate")
	f.name = "Details"
	f.logo = f:CreateTexture(nil, "overlay")
	f.logo:SetPoint("center", f, "center", 0, 0)
	f.logo:SetPoint("top", f, "top", 25, 56)
	f.logo:SetTexture([[Interface\AddOns\Details\images\logotipo]])
	f.logo:SetSize(256, 128)
	--InterfaceOptions_AddCategory (f)

	--open options panel
	f.options_button = CreateFrame("button", nil, f)
	f.options_button:SetText(Loc ["STRING_INTERFACE_OPENOPTIONS"])
	f.options_button:SetPoint("topleft", f, "topleft", 10, -100)
	f.options_button:SetHeight(170)
	f.options_button:SetWidth(170)
	f.options_button:SetScript("OnClick", function(self)
		local lower_instance = Details:GetLowerInstanceNumber()
		if (not lower_instance) then
			--no window opened?
			local instance1 = Details.tabela_instancias [1]
			if (instance1) then
				instance1:Enable()
				return Details:OpenOptionsWindow (instance1)
			else
				instance1 = Details:CriarInstancia(_, true)
				if (instance1) then
					return Details:OpenOptionsWindow (instance1)
				else
					Details:Msg(Loc["couldn't open options panel: no window available."])
				end
			end
		end
		Details:OpenOptionsWindow (Details:GetInstance(lower_instance))
	end)

	--create new window
	f.new_window_button = CreateFrame("button", nil, f)
	f.new_window_button:SetText(Loc ["STRING_MINIMAPMENU_NEWWINDOW"])
	f.new_window_button:SetPoint("topleft", f, "topleft", 10, -125)
	f.new_window_button:SetWidth(170)
	f.new_window_button:SetScript("OnClick", function(self)
		Details:CriarInstancia(_, true)
	end)


--update details version window
	function Details:OpenUpdateWindow()

		if (not _G.DetailsUpdateDialog) then
			local updatewindow_frame = CreateFrame("frame", "DetailsUpdateDialog", UIParent, "ButtonFrameTemplate")
			updatewindow_frame:SetFrameStrata("LOW")
			table.insert(UISpecialFrames, "DetailsUpdateDialog")
			updatewindow_frame:SetPoint("center", UIParent, "center")
			updatewindow_frame:SetSize(512, 200)
			--updatewindow_frame.portrait:SetTexture([[Interface\CHARACTERFRAME\TEMPORARYPORTRAIT-FEMALE-GNOME]])

			--updatewindow_frame.TitleText:SetText(Loc["A New Version Is Available!"]) --10.0 fuck

			updatewindow_frame.midtext = updatewindow_frame:CreateFontString(nil, "artwork", "GameFontNormal")
			updatewindow_frame.midtext:SetText(Loc["Good news everyone!\nA new version has been forged and is waiting to be looted."])
			updatewindow_frame.midtext:SetPoint("topleft", updatewindow_frame, "topleft", 10, -90)
			updatewindow_frame.midtext:SetJustifyH("center")
			updatewindow_frame.midtext:SetWidth(370)

			updatewindow_frame.gnoma = updatewindow_frame:CreateTexture(nil, "artwork")
			updatewindow_frame.gnoma:SetPoint("topright", updatewindow_frame, "topright", -3, -59)
			updatewindow_frame.gnoma:SetTexture("Interface\\AddOns\\Details\\images\\icons2")
			updatewindow_frame.gnoma:SetSize(105*1.05, 107*1.05)
			updatewindow_frame.gnoma:SetTexCoord(0.2021484375, 0, 0.7919921875, 1)

			local editbox = Details.gump:NewTextEntry(updatewindow_frame, nil, "$parentTextEntry", "text", 387, 14)
			editbox:SetPoint(20, -136)
			editbox:SetAutoFocus(false)
			editbox:SetHook("OnEditFocusGained", function()
				editbox.text = "http://www.curse.com/addons/wow/details"
				editbox:HighlightText()
			end)
			editbox:SetHook("OnEditFocusLost", function()
				editbox.text = "http://www.curse.com/addons/wow/details"
				editbox:HighlightText()
			end)
			editbox:SetHook("OnChar", function()
				editbox.text = "http://www.curse.com/addons/wow/details"
				editbox:HighlightText()
			end)
			editbox.text = "http://www.curse.com/addons/wow/details"

			updatewindow_frame.close = CreateFrame("Button", "DetailsUpdateDialogCloseButton", updatewindow_frame)
			updatewindow_frame.close:SetPoint("bottomleft", updatewindow_frame, "bottomleft", 8, 4)
			updatewindow_frame.close:SetText(Loc["Close"])

			updatewindow_frame.close:SetScript("OnClick", function(self)
				DetailsUpdateDialog:Hide()
				editbox:ClearFocus()
			end)

			updatewindow_frame:SetScript("OnHide", function()
				editbox:ClearFocus()
			end)

			function Details:UpdateDialogSetFocus()
				DetailsUpdateDialog:Show()
				DetailsUpdateDialogTextEntry.MyObject:SetFocus()
				DetailsUpdateDialogTextEntry.MyObject:HighlightText()
			end
			Details:ScheduleTimer("UpdateDialogSetFocus", 1)
		end
	end



--minimap icon and hotcorner
	function Details:RegisterMinimap()
		local LDB = LibStub("LibDataBroker-1.1", true)
		local LDBIcon = LDB and LibStub("LibDBIcon-1.0", true)

		if LDB then
			local databroker = LDB:NewDataObject ("Details", {
				type = "data source",
				icon = [[Interface\AddOns\Details\images\minimap]],
				text = "0",

				HotCornerIgnore = true,

				OnClick = function(self, button)
					if (button == "LeftButton") then
						if (IsControlKeyDown()) then
							Details:ToggleWindows()
							return
						end
						--1 = open options panel
						if (Details.minimap.onclick_what_todo == 1) then

							if (_G.DetailsOptionsWindow) then
								if (_G.DetailsOptionsWindow:IsShown()) then
									_G.DetailsOptionsWindow:Hide()
									return
								end
							end

							local lower_instance = Details:GetLowerInstanceNumber()
							if (not lower_instance) then
								local instance = Details:GetInstance(1)
								Details.CriarInstancia (_, _, 1)
								Details:OpenOptionsWindow (instance)
							else
								Details:OpenOptionsWindow (Details:GetInstance(lower_instance))
							end

						--2 = reset data
						elseif (Details.minimap.onclick_what_todo == 2) then
							Details.tabela_historico:ResetAllCombatData()

						--3 = show hide windows
						elseif (Details.minimap.onclick_what_todo == 3) then
							local opened = Details:GetOpenedWindowsAmount()

							if (opened == 0) then
								Details:ReabrirTodasInstancias()
							else
								Details:ShutDownAllInstances()
							end
						end

					elseif (button == "RightButton") then
						if (IsControlKeyDown() and SlashCmdList["SCORE"]) then  -- 自行加入支援 M+計分板
							SlashCmdList["SCORE"]("open")
							return
						end
						--minimap menu
						GameTooltip:Hide()
						local GameCooltip = GameCooltip

						GameCooltip:Reset()
						GameCooltip:SetType ("menu")
						GameCooltip:SetOption("ButtonsYMod", -5)
						GameCooltip:SetOption("HeighMod", 5)
						GameCooltip:SetOption("TextSize", 14)

						--reset
						GameCooltip:AddMenu (1, Details.tabela_historico.ResetAllCombatData, true, nil, nil, Loc ["STRING_ERASE_DATA"], nil, true)
						GameCooltip:AddIcon ([[Interface\COMMON\VOICECHAT-MUTED]], 1, 1, 14, 14)

						GameCooltip:AddLine("$div")

						--nova instancia
						GameCooltip:AddMenu (1, Details.CriarInstancia, true, nil, nil, Loc ["STRING_MINIMAPMENU_NEWWINDOW"], nil, true)
						--GameCooltip:AddIcon ([[Interface\Buttons\UI-AttributeButton-Encourage-Up]], 1, 1, 10, 10, 4/16, 12/16, 4/16, 12/16)
						GameCooltip:AddIcon ([[Interface\AddOns\Details\images\icons]], 1, 1, 12, 11, 462/512, 473/512, 1/512, 11/512)

						--reopen all windows
						GameCooltip:AddMenu (1, Details.ReabrirTodasInstancias, true, nil, nil, Loc ["STRING_MINIMAPMENU_REOPENALL"], nil, true)
						GameCooltip:AddIcon ([[Interface\Buttons\UI-MicroStream-Green]], 1, 1, 14, 14, 0.1875, 0.8125, 0.84375, 0.15625)
						--close all windows
						GameCooltip:AddMenu (1, Details.ShutDownAllInstances, true, nil, nil, Loc ["STRING_MINIMAPMENU_CLOSEALL"], nil, true)
						GameCooltip:AddIcon ([[Interface\Buttons\UI-MicroStream-Red]], 1, 1, 14, 14, 0.1875, 0.8125, 0.15625, 0.84375)

						GameCooltip:AddLine("$div")

						--lock
						GameCooltip:AddMenu (1, Details.TravasInstancias, true, nil, nil, Loc ["STRING_MINIMAPMENU_LOCK"], nil, true)
						GameCooltip:AddIcon ([[Interface\PetBattles\PetBattle-LockIcon]], 1, 1, 14, 14, 0.0703125, 0.9453125, 0.0546875, 0.9453125)

						GameCooltip:AddMenu (1, Details.DestravarInstancias, true, nil, nil, Loc ["STRING_MINIMAPMENU_UNLOCK"], nil, true)
						GameCooltip:AddIcon ([[Interface\PetBattles\PetBattle-LockIcon]], 1, 1, 14, 14, 0.0703125, 0.9453125, 0.0546875, 0.9453125, "gray")

						GameCooltip:AddLine("$div")

						--disable minimap icon
						local disable_minimap = function()
							Details.minimap.hide = not value

							LDBIcon:Refresh ("Details", Details.minimap)
							if (Details.minimap.hide) then
								LDBIcon:Hide ("Details")
							else
								LDBIcon:Show ("Details")
							end
						end
						GameCooltip:AddMenu (1, disable_minimap, true, nil, nil, Loc ["STRING_MINIMAPMENU_HIDEICON"], nil, true)
						GameCooltip:AddIcon ([[Interface\Buttons\UI-Panel-HideButton-Disabled]], 1, 1, 14, 14, 7/32, 24/32, 8/32, 24/32, "gray")

						--

						GameCooltip:SetBackdrop(1, Details.tooltip_backdrop, nil, Details.tooltip_border_color)
						GameCooltip:SetWallpaper (1, [[Interface\SPELLBOOK\Spellbook-Page-1]], {.6, 0.1, 0.64453125, 0}, {.8, .8, .8, 0.2}, true)

						GameCooltip:SetOwner(self, "topright", "bottomleft")
						GameCooltip:ShowCooltip()


					end
				end,
				OnTooltipShow = function(tooltip)
					tooltip:AddLine("Details!", 1, 1, 1)
					if (Details.minimap.onclick_what_todo == 1) then
						tooltip:AddLine(Loc ["STRING_MINIMAP_TOOLTIP1"])
					elseif (Details.minimap.onclick_what_todo == 2) then
						tooltip:AddLine(Loc ["STRING_MINIMAP_TOOLTIP11"])
					elseif (Details.minimap.onclick_what_todo == 3) then
						tooltip:AddLine(Loc ["STRING_MINIMAP_TOOLTIP12"])
					end
					tooltip:AddLine(Loc ["STRING_MINIMAP_TOOLTIP2"])
					tooltip:AddLine(Loc["|cFFCFCFCFctrl + left click|r: show/hide windows"])
					if SlashCmdList["SCORE"] then -- 自行加入支援 M+ 計分板
						tooltip:AddLine(Loc["|cFFCFCFCFctrl + right click|r: show/hide Mythic+ scoreboard"])
					end
				end,
			})

			if (databroker and not LDBIcon:IsRegistered ("Details")) then
				LDBIcon:Register ("Details", databroker, self.minimap)
			end

			Details.databroker = databroker
		end
	end

	function Details:DoRegisterHotCorner()
		--register lib-hotcorners
		local on_click_on_hotcorner_button = function(frame, button)
			if (Details.hotcorner_topleft.onclick_what_todo == 1) then
				local lower_instance = Details:GetLowerInstanceNumber()
				if (not lower_instance) then
					local instance = Details:GetInstance(1)
					Details.CriarInstancia (_, _, 1)
					Details:OpenOptionsWindow (instance)
				else
					Details:OpenOptionsWindow (Details:GetInstance(lower_instance))
				end

			elseif (Details.hotcorner_topleft.onclick_what_todo == 2) then
				Details.tabela_historico:ResetAllCombatData()
			end
		end

		local quickclick_func1 = function(frame, button)
			Details.tabela_historico:ResetAllCombatData()
		end

		local quickclick_func2 = function(frame, button)
			local lower_instance = Details:GetLowerInstanceNumber()
			if (not lower_instance) then
				local instance = Details:GetInstance(1)
				Details.CriarInstancia (_, _, 1)
				Details:OpenOptionsWindow (instance)
			else
				Details:OpenOptionsWindow (Details:GetInstance(lower_instance))
			end
		end

		local tooltip_hotcorner = function()
			GameTooltip:AddLine("Details!", 1, 1, 1, 1)
			if (Details.hotcorner_topleft.onclick_what_todo == 1) then
				GameTooltip:AddLine(Loc["|cFF00FF00Left Click:|r open options panel."], 1, 1, 1, 1)

			elseif (Details.hotcorner_topleft.onclick_what_todo == 2) then
				GameTooltip:AddLine(Loc["|cFF00FF00Left Click:|r clear all segments."], 1, 1, 1, 1)

			end
		end

		if (_G.HotCorners) then
			_G.HotCorners:RegisterHotCornerButton (
				--absolute name
				"Details",
				--corner
				"TOPLEFT",
				--config table
				Details.hotcorner_topleft,
				--frame _G name
				"DetailsLeftCornerButton",
				--icon
				[[Interface\AddOns\Details\images\minimap]],
				--tooltip
				tooltip_hotcorner,
				--click function
				on_click_on_hotcorner_button,
				--menus
				nil,
				--quick click
				{
					{func = quickclick_func1, name = Loc["Details! - Reset Data"]},
					{func = quickclick_func2, name = Loc["Details! - Open Options"]}
				},
				--onenter
				nil,
				--onleave
				nil,
				--is install
				true
			)
		end
	end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ~API

function Details:InitializeAPIWindow()
	local DetailsAPI2Frame = gump:CreateSimplePanel(UIParent, 700, 480, "Details! API", "DetailsAPI2Frame")
	DetailsAPI2Frame.Frame = DetailsAPI2Frame
	DetailsAPI2Frame.__name = "API"
	DetailsAPI2Frame.real_name = "DETAILS_APIWINDOW"
	DetailsAPI2Frame.__icon = [[Interface\AddOns\Details\images\icons]]
	DetailsAPI2Frame.__iconcoords = {449/512, 480/512, 62/512, 83/512}
	DetailsAPI2Frame.__iconcolor = "DETAILS_API_ICON"
	DetailsPluginContainerWindow.EmbedPlugin(DetailsAPI2Frame, DetailsAPI2Frame, true)

	function DetailsAPI2Frame.RefreshWindow()
		Details.OpenAPI()
	end
end

function Details.OpenAPI()
	--create the window if not loaded yet
	Details:CreateAPI2Frame()

	DetailsAPI2Frame:Show()
	DetailsAPI2Frame.Refresh() --doesn't exists?
	DetailsPluginContainerWindow.OpenPlugin(DetailsAPI2Frame)
end

function Details:LoadFramesForBroadcastTools()
	--event tracker
	--if enabled and not loaded, load it
	if (Details.event_tracker.enabled and not Details.Broadcaster_EventTrackerLoaded) then
		Details:CreateEventTrackerFrame(UIParent, "DetailsEventTracker")
	end

	--if enabled and loaded, refresh and show
	if (Details.event_tracker.enabled and Details.Broadcaster_EventTrackerLoaded) then
		Details:UpdateEventTrackerFrame()
		_G.DetailsEventTracker:Show()
	end

	--if not enabled but loaded, hide it
	if (not Details.event_tracker.enabled and Details.Broadcaster_EventTrackerLoaded) then
		_G.DetailsEventTracker:Hide()
	end

	--current dps
	local bIsEnabled = Details.realtime_dps_meter.enabled and (Details.realtime_dps_meter.arena_enabled or Details.realtime_dps_meter.mythic_dungeon_enabled)

	--if enabled and not loaded, load it
	if (bIsEnabled and not Details.Broadcaster_CurrentDpsLoaded) then
		Details:CreateCurrentDpsFrame(UIParent, "DetailsCurrentDpsMeter")
	end

	--if enabled, check if can show
	if (bIsEnabled and Details.Broadcaster_CurrentDpsLoaded) then
		if (Details.realtime_dps_meter.mythic_dungeon_enabled) then
			local zoneName, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceMapID, instanceGroupSize = GetInstanceInfo()
			if (difficultyID == 8) then
				--player is inside a mythic dungeon
				_G.DetailsCurrentDpsMeter:StartForMythicDungeon()
			end
		end

		if (Details.realtime_dps_meter.arena_enabled) then
			local zoneName, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceMapID, instanceGroupSize = GetInstanceInfo()
			if (instanceType == "arena") then
				--player is inside an arena
				_G.DetailsCurrentDpsMeter:StartForArenaMatch()
			end
		end
	end

	--if not enabled but loaded, hide it
	if (not bIsEnabled and Details.Broadcaster_CurrentDpsLoaded) then
		_G.DetailsCurrentDpsMeter:Hide()
	end
end


function Details:FormatBackground(frame) --deprecated I guess
	frame:SetBackdrop({edgeFile = [[Interface\Buttons\WHITE8X8]], edgeSize = 1, bgFile = [[Interface\AddOns\Details\images\background]], tileSize = 64, tile = true})
	frame:SetBackdropColor(.5, .5, .5, .5)
	frame:SetBackdropBorderColor(0, 0, 0, 1)

	if (not frame.__background) then
		frame.__background = frame:CreateTexture(nil, "background")
	end

	frame.__background:SetTexture([[Interface\AddOns\Details\images\background]], true)
	frame.__background:SetAlpha(0.7)
	frame.__background:SetVertexColor(0.27, 0.27, 0.27)
	frame.__background:SetVertTile(true)
	frame.__background:SetHorizTile(true)
	frame.__background:SetAllPoints()
end


function Details.ShowCopyValueFrame(textToShow)
	if (not DetailsCopyValueFrame) then
		local frame = CreateFrame("frame", "DetailsCopyValueFrame", UIParent)
		frame:SetSize(160, 20)
		frame:SetPoint("center", UIParent, "center", 0, 0)
		DetailsFramework:ApplyStandardBackdrop(frame)
		table.insert(UISpecialFrames, "DetailsCopyValueFrame")

		frame.editBox = CreateFrame("editbox", nil, frame)
		frame.editBox:SetPoint("topleft", frame, "topleft")
		frame.editBox:SetAutoFocus(false)
		frame.editBox:SetFontObject("GameFontHighlightSmall")
		frame.editBox:SetAllPoints()
		frame.editBox:SetJustifyH("center")
		frame.editBox:EnableMouse(true)

		frame.editBox:SetScript("OnEnterPressed", function()
			frame.editBox:ClearFocus()
			frame:Hide()
		end)

		frame.editBox:SetScript("OnEscapePressed", function()
			frame.editBox:ClearFocus()
			frame:Hide()
		end)

		frame.editBox:SetScript("OnChar", function()
			frame.editBox:ClearFocus()
			frame:Hide()
		end)
	end

	DetailsCopyValueFrame:Show()
	DetailsCopyValueFrame.editBox:SetText(textToShow or "")
	DetailsCopyValueFrame.editBox:SetFocus()
	DetailsCopyValueFrame.editBox:HighlightText()
end