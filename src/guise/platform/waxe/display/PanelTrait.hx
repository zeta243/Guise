package guise.platform.waxe.display;
import wx.Window;
import wx.Panel;


class PanelTrait extends ContainerTrait<Panel>
{

	public function new() {
		super(function(parent:Window):Panel return Panel.create(parent) );
	}
	
}