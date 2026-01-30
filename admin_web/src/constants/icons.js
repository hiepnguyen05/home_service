import {
    MdCleaningServices,
    MdWaterDrop,
    MdBolt,
    MdAcUnit,
    MdFormatPaint,
    MdLocalShipping,
    MdLocalLaundryService,
    MdConstruction,
    MdPestControl,
    MdYard,
    MdPlumbing,
    MdLightbulb,
    MdBuild,
    MdHomeRepairService,
    MdSettings
} from "react-icons/md";

export const ICON_LIST = [
    { name: 'cleaning_services', label: 'Vệ sinh', component: MdCleaningServices },
    { name: 'water_drop', label: 'Nước', component: MdWaterDrop },
    { name: 'bolt', label: 'Điện', component: MdBolt },
    { name: 'lightbulb', label: 'Bóng đèn', component: MdLightbulb },
    { name: 'ac_unit', label: 'Điều hoà', component: MdAcUnit },
    { name: 'format_paint', label: 'Sơn', component: MdFormatPaint },
    { name: 'local_shipping', label: 'Vận chuyển', component: MdLocalShipping },
    { name: 'local_laundry_service', label: 'Giặt ủi', component: MdLocalLaundryService },
    { name: 'construction', label: 'Xây dựng', component: MdConstruction },
    { name: 'pest_control', label: 'Côn trùng', component: MdPestControl },
    { name: 'yard', label: 'Sân vườn', component: MdYard },
    { name: 'plumbing', label: 'Ống nước', component: MdPlumbing },
    { name: 'build', label: 'Sửa chữa', component: MdBuild },
    { name: 'home_repair_service', label: 'Dụng cụ', component: MdHomeRepairService },
    { name: 'settings', label: 'Cài đặt', component: MdSettings },
];

export const getIconComponent = (iconName) => {
    const icon = ICON_LIST.find(i => i.name === iconName);
    return icon ? icon.component : MdBuild; // Default fallback
};
