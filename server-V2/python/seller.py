class Seller:
    def __init__(self, id_, order, num, price):
        self.id = id_
        self.order = order
        self.sale = num
        self.num = num
        self.price = price
        self.__buyer = {}
        self.__preference = {}
        # buy 是一个字典，其中键表示买家的id，值表示交易量
        self.buy = {}

    def set_buyer(self, k, v):
        self.__buyer[k] = v

    # 获取偏好列表
    def set_seller_pre(self):
        p = 1
        a_sort_list = sorted(self.__buyer.items(), key=lambda x: (x[1].price, 20 - x[1].order), reverse=True)
        pre_dic = {}
        for each_b, s_obj in a_sort_list:
            pre_dic[each_b] = p
            p += 1
        self.__preference = pre_dic
        for b_, value in self.buy.items():
            value[1] = self.__preference[b_]

    # 类外访问偏好列表
    def get_pre(self, B):
        return self.__preference[B]
