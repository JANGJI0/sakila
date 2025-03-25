<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql. *" %>
<%@ page import="java.util. *" %>
<!-- controller 단 -->
<%
	String storeId = request.getParameter("storeId");
	if(request.getParameter("storeId") ==null) {
		storeId = "0";
	}

	//검색
	String searchWord = request.getParameter("searchWord");
		//디버깅
		System.out.println("searchWord: " + searchWord);
		if(searchWord == null) {
			searchWord = "";
		}

	// 페이징
	int currentPage = 1;
	if(request.getParameter("currentPage") != null) {
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	int rowPerPage = 10;
	int startRow = (currentPage - 1) * rowPerPage;
	
// model 단
	// 1) mysql 드라이버 로딩 접속
	Class.forName("com.mysql.cj.jdbc.Driver");
		// 디버깅
		System.out.println("드라이버 로딩 성공");
	// 변수 받기
	Connection conn = null;
	PreparedStatement stmt = null;
	ResultSet rs = null;
	// 페이징 변수 받기
	PreparedStatement stmt2 = null;
	ResultSet rs2 = null;
	
	// 2) sql 준비
	// String sql = "SELECT * FROM rental where store_id = ?";

	String sql = " SELECT r.rental_id rentalId, f.title filmTitle,"
					+ " r.inventory_id inventoryId, c.customer_id customerId, CONCAT(c.first_name, ' ', c.last_name) customer,"
					+ " c.store_id storeId, r.rental_date rentalDate, r.return_date returnDate"
					+ " FROM rental r"
					+ " JOIN customer c ON r.customer_id = c.customer_id"
					+ " JOIN store s ON c.store_id = s.store_id"
					+ " JOIN inventory i ON r.inventory_id = i.inventory_id"
					+ " JOIN film f ON i.film_id = f.film_id"
					+ " ORDER BY r.rental_id ASC LIMIT ?, ?";
	String sql2 = " SELECT count(*) cnt"
					+ " FROM rental r"
					+ " JOIN customer c ON r.customer_id = c.customer_id"
					+ " JOIN store s ON c.store_id = s.store_id"
					+ " JOIN inventory i ON r.inventory_id = i.inventory_id"
					+ " JOIN film f ON i.film_id = f.film_id";
		
				
		// 디버깅
		System.out.println("sql: " + sql);
	// 3) connection(접속)하기
	conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/sakila", "root", "java1234");
		// 디버깅
		System.out.println("DB연결성공: " + conn);
		
	// 
	if(storeId.equals("0") && searchWord.equals("")) {  // 아무것도 선택 하지 않았을때
		stmt = conn.prepareStatement(sql);
		stmt2 = conn.prepareStatement(sql2);
		stmt.setInt(1, startRow);
		stmt.setInt(2, rowPerPage);
		
	} else if(!storeId.equals("0") && searchWord.equals("")) { // 지점만 입력 했을 때
		sql = " SELECT r.rental_id rentalId, f.title filmTitle,"
				+ " r.inventory_id inventoryId, c.customer_id customerId, CONCAT(c.first_name, ' ', c.last_name) customer,"
				+ " c.store_id storeId, r.rental_date rentalDate, r.return_date returnDate"
				+ " FROM rental r"
				+ " JOIN customer c ON r.customer_id = c.customer_id"
				+ " JOIN store s ON c.store_id = s.store_id"
				+ " JOIN inventory i ON r.inventory_id = i.inventory_id"
				+ " JOIN film f ON i.film_id = f.film_id WHERE c.store_id = ? ORDER BY r.rental_id LIMIT ?, ?";
		sql2 = " SELECT count(*) cnt" 
				+ " FROM rental r"
				+ " JOIN customer c ON r.customer_id = c.customer_id"
				+ " JOIN store s ON c.store_id = s.store_id"
				+ " JOIN inventory i ON r.inventory_id = i.inventory_id"
				+ " JOIN film f ON i.film_id = f.film_id"
				+ " WHERE c.store_id = ? ";
		stmt = conn.prepareStatement(sql);
		stmt2 = conn.prepareStatement(sql2);
		stmt.setInt(1, Integer.parseInt(storeId));
		stmt.setInt(2, startRow);
		stmt.setInt(3, rowPerPage);
		stmt2.setInt(1, Integer.parseInt(storeId));
				
	} else if(storeId.equals("0") && !searchWord.equals("")) { // 제목만 입력 했을 때
		sql = " SELECT r.rental_id rentalId, f.title filmTitle,"
				+ " r.inventory_id inventoryId, c.customer_id customerId, CONCAT(c.first_name, ' ', c.last_name) customer,"
				+ " c.store_id storeId, r.rental_date rentalDate, r.return_date returnDate"
				+ " FROM rental r"
				+ " JOIN customer c ON r.customer_id = c.customer_id"
				+ " JOIN store s ON c.store_id = s.store_id"
				+ " JOIN inventory i ON r.inventory_id = i.inventory_id"
				+ " JOIN film f ON i.film_id = f.film_id WHERE f.title like ? ORDER BY r.rental_id LIMIT ?, ?";
		sql2 = " SELECT count(*) cnt" 
				+ " FROM rental r"
				+ " JOIN customer c ON r.customer_id = c.customer_id"
				+ " JOIN store s ON c.store_id = s.store_id"
				+ " JOIN inventory i ON r.inventory_id = i.inventory_id"
				+ " JOIN film f ON i.film_id = f.film_id"
				+ " WHERE f.title like ? ";
		stmt = conn.prepareStatement(sql);
		stmt2 = conn.prepareStatement(sql2);
		stmt.setString(1, "%" + searchWord + "%");
		stmt.setInt(2, startRow);
		stmt.setInt(3, rowPerPage);
		stmt2.setString(1, "%" + searchWord + "%");
		
	} else { // 둘 다 입력 했을 때
		sql = " SELECT r.rental_id rentalId, f.title filmTitle,"
				+ " r.inventory_id inventoryId, c.customer_id customerId, CONCAT(c.first_name, ' ', c.last_name) customer,"
				+ " c.store_id storeId, r.rental_date rentalDate, r.return_date returnDate"
				+ " FROM rental r"
				+ " JOIN customer c ON r.customer_id = c.customer_id"
				+ " JOIN store s ON c.store_id = s.store_id"
				+ " JOIN inventory i ON r.inventory_id = i.inventory_id"
				+ " JOIN film f ON i.film_id = f.film_id WHERE c.store_id = ? AND f.title like ? ORDER BY r.rental_id LIMIT ?, ?";
		sql2 = " SELECT count(*) cnt" 
				+ " FROM rental r"
				+ " JOIN customer c ON r.customer_id = c.customer_id"
				+ " JOIN store s ON c.store_id = s.store_id"
				+ " JOIN inventory i ON r.inventory_id = i.inventory_id"
				+ " JOIN film f ON i.film_id = f.film_id"
				+ " WHERE c.store_id = ? AND f.title like ? ";
		stmt = conn.prepareStatement(sql);
		stmt2 = conn.prepareStatement(sql2);
		stmt.setInt(1, Integer.parseInt(storeId));
		stmt.setString(2, "%" + searchWord + "%");
		stmt.setInt(3, startRow);
		stmt.setInt(4, rowPerPage);
		stmt2.setInt(1, Integer.parseInt(storeId));
		stmt2.setString(2, "%" + searchWord + "%");
	}
	// 5) 쿼리 실행
	rs = stmt.executeQuery();
	rs2 = stmt2.executeQuery();
		// 디버깅		
		System.out.println("ResultSet: " + rs);
		System.out.println("ResultSet: " + rs2);
		
	// 전체 페이지
	int totalCnt = 0;
	if(rs2.next()) {
		totalCnt = rs2.getInt("cnt");
	}
	int lastPage = totalCnt / rowPerPage;
	if(totalCnt % rowPerPage != 0) {
		lastPage++;
	}
	// 디버깅 전체 행 수 출력 확인
	System.out.println("전체 행의 수: " + rs2.getInt("cnt"));
	
	//페이징 수 나타내기
	int pageCount = 5;
	int startPage = ((currentPage - 1) / pageCount) * pageCount + 1;
	int endPage = startPage + pageCount - 1;
	if(endPage > lastPage) {
		endPage = lastPage;
	}
	
	
			
	
	// 배열 리스트 받기
		ArrayList<HashMap<String, Object>> list = new ArrayList<HashMap<String, Object>>();
			while(rs.next()) {
				HashMap<String, Object> map = new HashMap<String, Object>();
				map.put("storeId", rs.getObject("storeId"));
				map.put("rentalId", rs.getObject("rentalId"));
				map.put("filmTitle", rs.getObject("filmTitle"));
				map.put("inventoryId", rs.getObject("inventoryId"));
				map.put("customer", rs.getObject("customer"));
				map.put("customerId", rs.getObject("customerId"));
				map.put("rentalDate", rs.getObject("rentalDate"));
				map.put("returnDate", rs.getObject("returnDate"));
				
				list.add(map);
	}
%>
<!-- view 단 -->
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title></title>
	<style>
	 .nolink {  /*링크 밑줄 제거 */
	 	text-decoration: none;
	 	color: black; /* 필요시 색상 지정 */
	 }
	 
	 	.nolink:hover {
	 		color: #007b; /* 마우스 오버 시 색상 변경 */
	 	}
	 	
	 	/*border말고 다른 테이블 코드*/
	 	table {
	 		width: 100%;
	 		border-collapse: separate; /* 중요: collapse명 둥글게 안 보임*/
	 		border-spacing: 50;		/* 셀 간격*/
	 		border-radus: 100px;		/* 둥근 모서리*/	
	 		overflow: hidden;        /* 꼭 필요: 둥근 모서리가 잘리지 않게*/
	 		box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1); /* 그림자도 예쁘게*/
	 	}	
	 	th, td {
	 		padding: 12px 16px;
	 		text-align: left;
	 		background-color: #fff;
	 	}
	 	
	 	th {
	 		background-color: #f4F4F4;
	 		front-weight: bold;
	 	}
	 	
	 	th:nth-child(even) {
	 		background-color: #f9f9f9;
	 	}
	 	
	 	th:hover {
	 		background-color: #eef6ff;
	 	}
	 	
	</style>
</head>
<body>
	<h1>Rental List</h1>
	<form action="/sakila/d0325/rentalList.jsp" method="get">
		Store : 
		<select name ="storeId">
			<option value="0" <%= storeId.equals("0") ? "selected" : ""%>>전체</option>
			<option value="1" <%= storeId.equals("1") ? "selected" : ""%>>1지점</option>
			<option value="2" <%= storeId.equals("2") ? "selected" : ""%>>2지점</option>
		</select>
		<button type="submit">검색</button>
	</form>
	
	<table>
		<tr>
			<th>rentalId</th>
			<th>filmTitle</th>
			<th>inventoryId</th>
			<th>name(customerId)</th> <!-- name = first_name + last_name -->
			<th>rentalDate</th>
			<th>returnDate</th>
		</tr>
		<%
			for(HashMap<String, Object> map : list) {
		%>
				
			<tr>
				<th><%=map.get("rentalId") %></th>
				<th><a class="nolink" href="/sakila/d0325/filmTitleDetail.jsp?filmTitle=<%=map.get("filmTitle")%>"><%=map.get("filmTitle") %></a></th>
				<th><%=map.get("inventoryId") %></th>
				<th><%=map.get("customer") %>(<%=map.get("customerId") %>)</th>
				<th><%=map.get("rentalDate") %></th>
				<th><%=map.get("returnDate") %></th>
			</tr>
		<%
			}
		%>
	</table>
	<form action="/sakila/d0325/rentalList.jsp">
		filmTitle Search word :
		<input type="text" name="searchWord" value="<%=searchWord%>">
		<input type="hidden" name="storeId" value="<%=storeId %>">  <!-- 지점 선택하고 검색을 해도 지점 유지 -->
		<button type="submit">검색</button>
		<a href= "/sakila//d0325/rentalList.jsp?">초기화</a>
	</form>
	<!-- 페이징 -->
		<a href="/sakila//d0325/rentalList.jsp?currentPage=1&storeId=<%=storeId %>&searchWord=<%=searchWord%>">[처음]</a>
		<%
			// 10개 이전 할 경우
			if(currentPage > 1) {
				int prevPage = currentPage - 10;
				if(prevPage < 1) prevPage = 1;
		%>
			<a href="/sakila//d0325/rentalList.jsp?currentPage=<%=prevPage %>&storeId=<%=storeId %>&searchWord=<%=searchWord%>">[이전]</a>
		<%
			}
			for(int i = startPage; i<= endPage; i++) {
		%>
			<a href="/sakila//d0325/rentalList.jsp?currentPage=<%=i %>&storeId=<%=storeId %>&searchWord=<%=searchWord%>">[<%=i %>]</a>
		<%
			}
		%>	
		<%
			// 10 다음 할 경우
			if(currentPage < lastPage) {
				int nextPage = currentPage + 10;
				if(nextPage > lastPage) nextPage = lastPage;
		%>
			<a href="/sakila//d0325/rentalList.jsp?currentPage=<%=nextPage %>&storeId=<%=storeId %>&searchWord=<%=searchWord%>">[다음]</a>
		<%
			}
		%>
			<a href="/sakila//d0325/rentalList.jsp?currentPage=<%=lastPage %>&storeId=<%=storeId %>&searchWord=<%=searchWord%>">[마지막]</a>
</body>
</html>




